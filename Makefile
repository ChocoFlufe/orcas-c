ARCH=i386
DISK_SIZE=512
FILESYSTEM=fat32

SRC=src
BUILD=build

ASM=yasm
ifeq ($(ARCH), i386)
	CC=clang --target=elf32-i386
else ifeq ($(ARCH), x86_64)
	CC=clang --target=elf64-x86_64
endif
LD=ld.lld
GDB=gdb
VM=qemu-system-$(ARCH)

CFLAGS= -march=i386 -ffreestanding -fno-builtin -nostdlib -nostdinc -fno-exceptions -fno-rtti -m32 -mno-red-zone -mcmodel=kernel -mno-red-zone -mno-mmx -Oz -c -g -Wall -fno-builtin-function -fno-builtin -fno-pie -fno-stack-protector -finline-functions -finline-functions -fpie -pipe -Iinclude/
ifeq ($(ARCH), i386)
	VMFLAGS= -cpu qemu32 -smp 4 -display sdl -vga std -device secondary-vga -machine pc -m 2048 -machine pc -device virtio-rng-pci -drive format=raw,media=disk,index=0,file=
else ifeq ($(ARCH), x86_64)
	VMFLAGS= -cpu qemu64 -smp 4 -display sdl -vga std -device secondary-vga -machine pc -m 2048 -machine pc -device virtio-rng-pci -drive format=raw,media=disk,index=0,file=
endif


C_SOURCES=$(filter-out $(shell find src/arch/ -name "*.c"), $(shell find src/ -name "*.c")) $(shell find src/arch/$(ARCH)/ -name "*.c")
# CXX_SOURCES=$(shell find . -name "*.cpp")
OBJ_SOURCES=$(foreach file,$(C_SOURCES),build/obj/$(basename $(notdir $(file))).o)

default: all

.PHONY: all clean run debug monitor strings xxd

all: clean $(BUILD)/OrcaS.img

clean:
	clear
	@rm -rf build/
	@mkdir -p build/bin/ build/obj/

run: $(BUILD)/OrcaS.img
	@$(VM) $(VMFLAGS)$< -serial stdio

debug: $(BUILD)/OrcaS.img $(BUILD)/obj/head.o objects
	$(LD) -o $(BUILD)/obj/kernel.elf -T link.ld $(word 2, $^) $(OBJ_SOURCES) --oformat elf32-i386 -nostdlib -Lgcc
	$(VM) $(VMFLAGS)$< -serial stdio -s -S &
	$(GDB) -tui -ex "layout split" -ex "target remote localhost:1234" -ex "symbol-file $(BUILD)/obj/kernel.elf" -ex "b kmain" -ex "display/i \$$pc" -ex "c"

monitor: $(BUILD)/OrcaS.img
	$(VM) $(VMFLAGS)$< -monitor stdio -action reboot=shutdown,shutdown=pause -s -S

$(BUILD)/OrcaS.img: $(BUILD)/bin/mbr.bin $(BUILD)/bin/orcas.bin
	@dd if=/dev/zero of=$@ bs=1048576 count=$(DISK_SIZE)
	@sfdisk $@ < $(FILESYSTEM).dump
ifeq ($(FILESYSTEM), fat32)
	@mkfs.vfat -F 32 --offset 2048 $@
	@dd if=$< of=$@ conv=notrunc bs=440 count=1 conv=notrunc
	@dd if=$(word 2,$^) of=$@ conv=notrunc bs=1 skip=90 seek=1048666 conv=notrunc
endif
	@# sudo losetup -o $(shell echo $$(( 2048 * 512 ))) --sizelimit $(shell echo $$(( 500 * 1024 * 1024))) -f $@

$(BUILD)/bin/orcas.bin: $(BUILD)/bin/vbr.bin $(BUILD)/bin/boot.bin $(BUILD)/bin/kernel.bin
	cat $^ > $@

$(BUILD)/bin/kernel.bin: $(BUILD)/obj/head.o objects
	$(LD) -o $@ -T link.ld $< $(OBJ_SOURCES) --oformat binary -nostdlib -Lgcc

$(BUILD)/obj/head.o: $(SRC)/arch/$(ARCH)/head.asm
ifeq ($(ARCH), i386)
	$(ASM) -w+all $^ -f elf32 -o $@
else ifeq ($(ARCH), x86_64)
	$(ASM) -w+all $^ -f elf64 -o $@
endif

objects: $(C_SOURCES)
	clear
	@echo $(C_SOURCES)
	@$(foreach file,$(C_SOURCES),$(CC) $(CFLAGS) $(file) -o build/obj/$(basename $(notdir $(file))).o;)
	@# cd include/fonts/; cp $(FONT) font.psf; objcopy -O elf64-x86-64 -B i386 -I binary font.psf ../../$(BUILD)/obj/font.o; rm -rf font.psf

$(BUILD)/bin/boot.bin: $(SRC)/boot/arch/$(ARCH)/boot.asm
	$(ASM) -w+all $^ -f bin -o $@

$(BUILD)/bin/vbr.bin: $(SRC)/boot/fs/$(FILESYSTEM)/vbr.asm
	$(ASM) -w+all $^ -f bin -o $@

$(BUILD)/bin/mbr.bin: $(SRC)/boot/mbr.asm
	$(ASM) -w+all $^ -f bin -o $@

strings: $(BUILD)/OrcaS.img
	@strings -t x $^

xxd: $(BUILD)/OrcaS.img
	@xxd -a $^
