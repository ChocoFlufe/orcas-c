#ifndef CPU_GDT_H
#define CPU_GDT_H

#include <kernel/utils.h>

extern void load_gdt(uint32_t gdt_ptr, uint16_t code_segment, uint16_t data_segment);

void init_gdt();

#endif
