%define BASE 0x7c00
%define KERNEL 0xa000

org 0x7c00
bits 16

_start:
    jmp 0:boot

boot:
    cli
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; Setup stack
    mov bp, BASE
    mov ss, ax
    mov sp, bp
    ; Store VBR values
    mov [BOOT_DRIVE], dl
    mov [PART_OFFSET], si

load_unreal:
    push ds
    push es
    ; Enable A20
    in al, 0x92
    or al, 2
    out 0x92, al
    ; Load flat GDT descriptor
    lgdt [gdtr]
    ; Switch to protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp $+2
    ; Protected mode
    mov bx, 0x18
    mov ds, bx
    and al, 0xfe
    mov cr0, eax

    pop es
    pop ds

unreal:
    ; Detect VGA support
    push es
    mov ax, 0x1a00
    int 0x10
    pop es
    test al, 0x1a
    jz err.vga
    ; Detect VBE support
    ; push es
    ; mov ax, 0x4f00
    ; mov di, vesa_info_block
    ; int 0x10
    ; pop es
    ; test ah, 0
    ; jnz err.vbe
    ; Set video mode
    ; push es
    ; mov ax, 0x4f02
    ; mov bx, 0x4107
    ; int 0x10
    ; pop es
    ; test ah, 0
    ; jnz err.vbe
    ; ; Get Mode Info
    ; push es
    ; mov ax, 0x4f01
    ; mov cx, 0x107
    ; mov di, vesa_mode_info_block
    ; int 0x10
    ; pop es
    mov ax, 0x13
    int 0x10
    ; PIC

    sti

detect_mem_entries:
    mov di, 0x8000
    xor ebx, ebx
    xor bp, bp
    mov edx, 0x0534D4150
    mov eax, 0xe820
    mov [di + 20], dword 1
    mov ecx, 24
    int 0x15
    jc .error
    mov  edx, 0x0534D4150
    cmp  eax, edx
    jne .error
    test ebx, ebx
    je  .error
    jmp .mid
.error:
    stc
    jmp load_kernel
.loop:
    mov  eax, 0xe820
    mov  [di + 20], dword 1
    mov  ecx, 24
    int  0x15
    jc .end
    mov  edx, 0x0534D4150
.mid:
    jcxz .skip_entry
    cmp  cl, 20
    jbe .no_text
    test byte [di + 20], 1
    je   short .skip_entry
.no_text:
    mov  ecx, [di + 8]
    or   ecx, [di + 12]
    jz   .skip_entry
    inc  bp
    add  di, 24
.skip_entry:
    test ebx, ebx
    jne  short .loop
.end:
    mov [MMAP_ENTRIES], bp
    clc

load_kernel:
    mov [PART_OFFSET], si
    mov ebx, dword [si + 8]
    add ebx, 2
    ; Setup DAP
    push dword 0
    push ebx
    push word 0
    push word KERNEL
    push word 32
    push word 0x10
    mov ah, 0x42
    mov dl, byte [BOOT_DRIVE]
    mov si, sp
    int 0x13
    jc err.disk
    add sp, 16

map_mem:
    ; int 0x12
    ; mov [0x9100], ax
    mov ah, 0x88
    int 0x15
    mov [0x9100], ax

load_pmode:
    cli
    lgdt [gdtr]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 8:pmode

err:
.vga:
    mov si, 1
    jmp .stall
.vbe:
    mov si, 2
    jmp .stall
.disk:
    mov si, 3
    jmp .stall
.stall:
    hlt
    jmp $-1

bits 32

pmode:
    mov ax, 0x10
    mov ebp, 0x7ffff
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, ebp

    mov ax, [PART_OFFSET]
    mov bx, [MMAP_ENTRIES]
    mov dl, [BOOT_DRIVE]
    call KERNEL
    hlt
    jmp $-1

BOOT_DRIVE: resb 1
PART_OFFSET: resw 1
MMAP_ENTRIES: resw 1

%include "../../gdt.asm"

padding: times 510 - ($-$$) db 0
signature: dw 0xaa55

; vesa_info_block:
;     .signature: db "VBE2"
;     .ver: resw 1
;     .oem_prt: resd 1
;     .capabilities: resd 1
;     .vid_modes_offsets: resw 1
;     .vid_modes_segment: resw 1
;     .block_clock: resw 1
;     .oem_software_ver: resw 1
;     .oem_vender_ptr: resd 1
;     .oem_product_name_ptr: resd 1
;     .oem_product_ver_ptr: resd 1
;     .res: resb 222
;     .oem_data: resb 256

 ; vesa_mode_info_block:
 ;    .modeattributes: resw 1
 ;    .firstwindowattributes: resb 1
 ;    .secondwindowattributes: resb 1
 ;    .windowgranularity: resw 1
 ;    .windowsize: resw 1
 ;    .firstwindowsegment: resw 1
 ;    .secondwindowsegment: resw 1
 ;    .windowfunctionptr: resd 1
 ;    .bytesperscanline: resw 1
 ;    .width: resw 1		;
 ;    .height: resw 1
 ;    .charwidth: resb 1
 ;    .charheight: resb 1
 ;    .planescount: resb 1
 ;    .bitsperpixel: resb 1
 ;    .bankscount: resb 1
 ;    .memorymodel: resb 1
 ;    .banksize: resb 1
 ;    .imagepagescount: resb 1
 ;    .reserved1: resb 1
 ;    .redmasksize: resb 1
 ;    .redfieldposition: resb 1
 ;    .greenmasksize: resb 1
 ;    .greenfieldposition: resb 1
 ;    .bluemasksize: resb 1
 ;    .bluefieldposition: resb 1
 ;    .reservedmasksize: resb 1
 ;    .reservedmaskposition: resb 1
 ;    .directcolormodeinfo: resb 1
 ;    .lfbaddress: resd 1
 ;    .offscreenmemoryoffset: resd 1
 ;    .offscreenmemorysize: resw 1
 ;    .reserved2: resb 206

; padding2: times 1022 - ($-$$) db 0
; signature2: dw 0xaa55
