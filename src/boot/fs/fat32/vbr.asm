org 0x9000
bits 16

%define BASE 0x7c00
%define INIT 0x9000

_start:
    jmp boot
    nop

bpb:
    .oem_id:            db "OrcaS   "
    .sector_size:       resw 1
    .sects_per_cluster: resb 1
    .reserved_sects:    resw 1
    .fat_count:         resb 1
    .root_dir_entries:  resw 1
    .sect_count16:      resw 1
    .media_type:        resb 1
    .sects_per_fat16:   resw 1
    .sects_per_track:   resw 1
    .heads_count:       resw 1
    .hidden_sects:      resd 1
    .sect_count32:      resd 1
ebr:
    .sects_per_fat32:   resd 1
    .flags:             resw 1
    .fat_ver:           resw 1
    .root_sect:         resd 1
    .fs_sect:           resw 1
    .backup_sect:       resw 1
    .res:               resd 3
    .drive_num:         resb 1
    .res1:              resb 1
    .boot_signature:    resb 1
    .vol_id:            resd 1
    .vol_label:         resb 11
    .filesystem_type:   resd 2
; times 87 resb 0

boot:
    cli
.relocate:
    cld
    mov cx, 0x100
    mov si, BASE
    mov di, INIT
    rep movsw

    jmp 0:load_kernel

load_kernel:
    mov byte [BOOT_DRIVE], dl
    mov word [PART_OFFSET], ax
    sti

    add ebx, 1
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
    mov si, [PART_OFFSET]

    jmp BASE

err:
.disk:
    mov si, 1
    jmp .stall
.boot:
    mov si, 2
    jmp .stall
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

padding: times 510 - ($-$$) db 0
signature: dw 0xaa55
