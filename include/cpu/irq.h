#ifndef CPU_IRQ_H
#define CPU_IRQ_H

#include <cpu/idt.h>
#include <drivers/io.h>

void load_irq();
void irq_handler(registers_t *regs);
void register_intr_handler(uint8_t intr, void (*handler)(registers_t *));
void unregister_intr_handler(uint8_t intr);

#endif
