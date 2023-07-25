%define BASE 0x7c00
%define INIT 0x600

org INIT
bits 16

_start:
    cli
    ; Setup segments
    xor si, si
    mov ds, si
    mov es, si
.relocate:
    cld
    mov cx, 0x100
    mov si, BASE
    mov di, INIT
    rep movsw

    jmp 0:mbr                   ; Far jump and set CS

mbr:
    ; Setup stack
    xor si, si
    mov	ss, si
    mov	sp, INIT
    ; Setup screen
    mov ax, 3
    int 0x10
    sti

    mov byte [BOOT_DRIVE], dl   ; Save drive type

    ; Configure serial port 0: 9600bps, no parity, 1 stop bit, 8 data bits
    mov ah, 0
    mov al, 11100011b
    mov dx, 0
    int 0x14

    ; Notify BIOS of 32/64 bit data usage in the future
    mov ax, 0xec00
    mov bl, 3
    int 0x15

    ; Check for BIOS interrupt 0x13 support
    mov ah, 0x41
    mov bx, 0x55aa
    mov dl, 0x80
    int 0x13
    jc err.int_13
    test cx, 1
    jz err.int_13

find_part:
    mov cx, 4
    mov bx, part_1
.loop:
    mov al, byte [bx]
    test al, 0x80               ; Check if partition is bootable
    jnz .found
    add bx, 0x10
    loop .loop
    jmp err.part
.found:                         ; See if any other partition is marked bootable
    push bx
    cmp cx, 0
    je load_vbr
.check_mbr
    add bx, 0x10
    mov al, [bx]
    test al, 0x80
    jnz err.mbr
    loop .check_mbr

load_vbr:
    pop si
    mov [PART_OFFSET], si
    mov ebx, dword [si + 8]
    ; Setup DAP
    push dword 0
    push ebx
    push word 0
    push word BASE
    push word 1
    push word 0x10
    mov ah, 0x42
    mov dl, byte [BOOT_DRIVE]
    mov si, sp
    int 0x13
    jc err.disk
    add sp, 16
    cmp word [0x7dfe], 0xaa55
    jne err.boot
    mov dl, [BOOT_DRIVE]
    mov ax, [PART_OFFSET]

    mov bp, BASE
    mov sp, bp

    jmp BASE

err:
.int_13:
    mov si, 1
    jmp .print
.part:
    mov si, 2
    jmp .print
.mbr:
    mov si, 3
    jmp .print
.boot:
    mov si, 4
    jmp .print
.disk:
    mov si, 5
    jmp .print
.print:
    add si, '0' | (0x4f << 8)
    push 0xb800
    pop es
    mov word [es:0], si
.stall:
    hlt
    jmp $ - 1

BOOT_DRIVE: resb 1
PART_OFFSET: resw 1

padding: times 0x1b8-($-$$) db 0

part_table:
disk_id: dd 0
reserved: dw 0
part_1:
    .attrib db 0
    .chs_start times 3 db 0
    .part_type db 0
    .chs_end times 3 db 0
    .lba_start dd 0
    .sect_count dd 0
part_2:
    .attrib db 0
    .chs_start times 3 db 0
    .part_type db 0
    .chs_end times 3 db 0
    .lba_start dd 0
    .sect_count dd 0
part_3:
    .attrib db 0
    .chs_start times 3 db 0
    .part_type db 0
    .chs_end times 3 db 0
    .lba_start dd 0
    .sect_count dd 0
part_4:
    .attrib db 0
    .chs_start times 3 db 0
    .part_type db 0
    .chs_end times 3 db 0
    .lba_start dd 0
    .sect_count dd 0
signature: dw 0xaa55
