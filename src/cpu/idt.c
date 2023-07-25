#include <cpu/idt.h>

typedef struct {
    uint16_t limit;
    uintptr_t base;
} __attribute__ ((packed)) idt_descriptor_t;

typedef struct {
    uint16_t base_low;
    uint16_t selector;
    uint8_t zero;
    uint8_t type;
    uint16_t base_high;
} __attribute__ ((packed)) idt_entry_t;

extern void load_idt(uint32_t idt_ptr);

idt_entry_t idt[256];
idt_descriptor_t idt_ptr;

void set_idt_gate(uint8_t i, uint32_t base, uint16_t selector, uint8_t type) {
    idt_entry_t *entry = &idt[i];

    entry->base_low = (base & 0xffff);
    entry->selector = selector;
    entry->zero = NULL;
    entry->type = type;
    entry->base_high = (base >> 16) & 0xffff;
}

void init_idt() {
    idt_ptr.limit = sizeof(idt) - 1;
    idt_ptr.base = (uintptr_t) &idt;

    bzero(&idt, sizeof(idt) - 1);

    load_idt((uintptr_t) &idt_ptr);
}
