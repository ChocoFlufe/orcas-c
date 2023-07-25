bits 32
extern kmain
extern isr_handler
extern irq_handler

section .entry

global _start
_start:
    mov [PART_OFFSET], ax
    mov [MMAP_ENTRIES], bx
    mov [BOOT_DRIVE], dl

    cli
    call kmain

    hlt
    jmp $-1

section .text

global load_gdt
load_gdt:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    lgdt [eax]

    mov eax, [ebp + 12]
    push eax
    push .reload
    retf
.reload:
    mov ax, [ebp + 16]
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, ebp
    pop ebp
    ret

global load_idt
load_idt:
    push ebp
    mov ebp, esp

    cli
    mov eax, [esp + 8]
    lidt [eax]

    mov esp, ebp
    pop ebp
    ret

isr_common_stub:
    pusha
    push ds

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld

    push esp
    call isr_handler
    add esp, 4

    pop ds
    popa

    add esp, 8
    iret

irq_common_stub:
    pusha
    push ds

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld

    push esp
    call irq_handler
    add esp, 4

    pop ds
    popa

    add esp, 8
    iret

; 0: Divide By Zero Exception
global isr0
isr0:
    push byte 0
    push byte 0
    jmp isr_common_stub

; 1: Debug Exception
global isr1
isr1:
    push byte 0
    push byte 1
    jmp isr_common_stub

; 2: Non Maskable Interrupt Exception
global isr2
isr2:
    push byte 0
    push byte 2
    jmp isr_common_stub

; 3: Int 3 Exception
global isr3
isr3:
    push byte 0
    push byte 3
    jmp isr_common_stub

; 4: INTO Exception
global isr4
isr4:
    push byte 0
    push byte 4
    jmp isr_common_stub

; 5: Out of Bounds Exception
global isr5
isr5:
    push byte 0
    push byte 5
    jmp isr_common_stub

; 6: Invalid Opcode Exception
global isr6
isr6:
    push byte 0
    push byte 6
    jmp isr_common_stub

; 7: Coprocessor Not Available Exception
global isr7
isr7:
    push byte 0
    push byte 7
    jmp isr_common_stub

; 8: Double Fault Exception (With Error Code!)
global isr8
isr8:
    push byte 8
    jmp isr_common_stub

; 9: Coprocessor Segment Overrun Exception
global isr9
isr9:
    push byte 0
    push byte 9
    jmp isr_common_stub

; 10: Bad TSS Exception (With Error Code!)
global isr10
isr10:
    push byte 10
    jmp isr_common_stub

; 11: Segment Not Present Exception (With Error Code!)
global isr11
isr11:
    push byte 11
    jmp isr_common_stub

; 12: Stack Fault Exception (With Error Code!)
global isr12
isr12:
    push byte 12
    jmp isr_common_stub

; 13: General Protection Fault Exception (With Error Code!)
global isr13
isr13:
    push byte 13
    jmp isr_common_stub

; 14: Page Fault Exception (With Error Code!)
global isr14
isr14:
    push byte 14
    jmp isr_common_stub

; 15: Reserved Exception
global isr15
isr15:
    push byte 0
    push byte 15
    jmp isr_common_stub

; 16: Floating Point Exception
global isr16
isr16:
    push byte 0
    push byte 16
    jmp isr_common_stub

; 17: Alignment Check Exception
global isr17
isr17:
    push byte 0
    push byte 17
    jmp isr_common_stub

; 18: Machine Check Exception
global isr18
isr18:
    push byte 0
    push byte 18
    jmp isr_common_stub

; 19: Reserved
global isr19
isr19:
    push byte 0
    push byte 19
    jmp isr_common_stub

; 20: Reserved
global isr20
isr20:
    push byte 0
    push byte 20
    jmp isr_common_stub

; 21: Reserved
global isr21
isr21:
    push byte 0
    push byte 21
    jmp isr_common_stub

; 22: Reserved
global isr22
isr22:
    push byte 0
    push byte 22
    jmp isr_common_stub

; 23: Reserved
global isr23
isr23:
    push byte 0
    push byte 23
    jmp isr_common_stub

; 24: Reserved
global isr24
isr24:
    push byte 0
    push byte 24
    jmp isr_common_stub

; 25: Reserved
global isr25
isr25:
    push byte 0
    push byte 25
    jmp isr_common_stub

; 26: Reserved
global isr26
isr26:
    push byte 0
    push byte 26
    jmp isr_common_stub

; 27: Reserved
global isr27
isr27:
    push byte 0
    push byte 27
    jmp isr_common_stub

; 28: Reserved
global isr28
isr28:
    push byte 0
    push byte 28
    jmp isr_common_stub

; 29: Reserved
global isr29
isr29:
    push byte 0
    push byte 29
    jmp isr_common_stub

; 30: Reserved
global isr30
isr30:
    push byte 0
    push byte 30
    jmp isr_common_stub

; 31: Reserved
global isr31
isr31:
    push byte 0
    push byte 31
    jmp isr_common_stub

; IRQ handlers
global irq0
irq0:
    push byte 0
    push byte 32
    jmp irq_common_stub

global irq1
irq1:
    push byte 1
    push byte 33
    jmp irq_common_stub

global irq2
irq2:
    push byte 2
    push byte 34
    jmp irq_common_stub

global irq3
irq3:
    push byte 3
    push byte 35
    jmp irq_common_stub

global irq4
irq4:
    push byte 4
    push byte 36
    jmp irq_common_stub

global irq5
irq5:
    push byte 5
    push byte 37
    jmp irq_common_stub

global irq6
irq6:
    push byte 6
    push byte 38
    jmp irq_common_stub

global irq7
irq7:
    push byte 7
    push byte 39
    jmp irq_common_stub

global irq8
irq8:
    push byte 8
    push byte 40
    jmp irq_common_stub

global irq9
irq9:
    push byte 9
    push byte 41
    jmp irq_common_stub

global irq10
irq10:
    push byte 10
    push byte 42
    jmp irq_common_stub

global irq11
irq11:
    push byte 11
    push byte 43
    jmp irq_common_stub

global irq12
irq12:
    push byte 12
    push byte 44
    jmp irq_common_stub

global irq13
irq13:
    push byte 13
    push byte 45
    jmp irq_common_stub

global irq14
irq14:
    push byte 14
    push byte 46
    jmp irq_common_stub

global irq15
irq15:
    push byte 15
    push byte 47
    jmp irq_common_stub

section .data

global PART_OFFSET
    PART_OFFSET: resw 1
global MMAP_ENTRIES
    MMAP_ENTRIES: resw 1
global BOOT_DRIVE
    BOOT_DRIVE: resb 1
