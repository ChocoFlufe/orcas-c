#ifndef CPU_IDT_H
#define CPU_IDT_H

#include <kernel/utils.h>

typedef struct {
    uint32_t ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t intr_no, err_no;
    uint32_t eip, cs, efl, useresp, ss;
} registers_t;

void set_idt_gate(uint8_t i, uint32_t base, uint16_t selector, uint8_t type);
void init_idt();

#endif
