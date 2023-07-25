#include <cpu/irq.h>

extern void irq0();
extern void irq1();
extern void irq2();
extern void irq3();
extern void irq4();
extern void irq5();
extern void irq6();
extern void irq7();
extern void irq8();
extern void irq9();
extern void irq10();
extern void irq11();
extern void irq12();
extern void irq13();
extern void irq14();
extern void irq15();

void *intr_handlers[256];

void load_irq() {
    set_idt_gate(32, (uint32_t) irq0, 0x08, 0x8E);
    set_idt_gate(33, (uint32_t) irq1, 0x08, 0x8E);
    set_idt_gate(34, (uint32_t) irq2, 0x08, 0x8E);
    set_idt_gate(35, (uint32_t) irq3, 0x08, 0x8E);
    set_idt_gate(36, (uint32_t) irq4, 0x08, 0x8E);
    set_idt_gate(37, (uint32_t) irq5, 0x08, 0x8E);
    set_idt_gate(38, (uint32_t) irq6, 0x08, 0x8E);
    set_idt_gate(39, (uint32_t) irq7, 0x08, 0x8E);
    set_idt_gate(40, (uint32_t) irq8, 0x08, 0x8E);
    set_idt_gate(41, (uint32_t) irq9, 0x08, 0x8E);
    set_idt_gate(42, (uint32_t) irq10, 0x08, 0x8E);
    set_idt_gate(43, (uint32_t) irq11, 0x08, 0x8E);
    set_idt_gate(44, (uint32_t) irq12, 0x08, 0x8E);
    set_idt_gate(45, (uint32_t) irq13, 0x08, 0x8E);
    set_idt_gate(46, (uint32_t) irq14, 0x08, 0x8E);
    set_idt_gate(47, (uint32_t) irq15, 0x08, 0x8E);

    asm volatile("sti");
}

void irq_handler(registers_t *regs) {
    if (intr_handlers[regs->intr_no] != NULL) {
        void (*handler)(registers_t *regs) = (void (*)(registers_t*))intr_handlers[regs->intr_no];
        handler(regs);
    }

    if (regs->intr_no >= 40)
        outb(0xa0, 0x20);
    outb(0x20, 0x20);
}

void register_intr_handler(uint8_t intr, void (*handler)(registers_t *)) {
    intr_handlers[intr] = (void*)handler;
}

void unregister_intr_handler(uint8_t intr) {
    intr_handlers[intr] = NULL;
}
