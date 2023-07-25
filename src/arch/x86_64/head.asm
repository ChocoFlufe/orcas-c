%define PAGE_ENTRIES 0x1000

bits 32
extern kmain

section .entry

global _start
_start:
    mov [PART_OFFSET], ax
    mov [MMAP_ENTRIES], bx
    mov [BOOT_DRIVE], dl

detect_cpuid:
    ; Store eflags to eax and ecx
    pushfd
    pop eax
    mov ecx, eax

    xor eax, 1 << 21

    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd

    xor eax,ecx
    jz err.cpuid

detect_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb err.unsupported

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz err.unsupported

setup_paging:
    mov edi, PAGE_ENTRIES
    mov cr3, edi

    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x4003
    add edi, 0x1000

    mov ebx, 3
    mov ecx, 512

.setup_entry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop .setup_entry

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

load_lmode:
    call setup_gdt64
    jmp 8:lmode

bits 64

lmode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

enable_sse:
    mov rax, cr0
    and ax, 11111101b
    or ax, 00000001b
    mov cr0, rax

    mov rax, cr4
    or ax, 1100000000b
    mov cr4, rax

jump_kernel:
    mov rbp, 0x80000
    mov rsp, rbp
    call kmain

    hlt
    jmp $-1

err:
.cpuid:
    mov si, 1
    jmp .stall
.unsupported:
    mov si, 2
    jmp .stall
.stall:
    hlt
    jmp $-1

%include "gdt.asm"

section .data

global PART_OFFSET
    PART_OFFSET: resw 1
global MMAP_ENTRIES
    MMAP_ENTRIES: resw 1
global BOOT_DRIVE
    BOOT_DRIVE: resb 1
