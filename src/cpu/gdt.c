#include <cpu/gdt.h>

#define KERNEL_CODE 8
#define KERNEL_DATA 0x10
#define USER_CODE 0x18
#define USER_DATA 0x20
// #define TASK_STATE 0x28

typedef struct {
    uint16_t size;
    uint32_t offset;
} __attribute__ ((packed)) gdt_descriptor_t;

typedef struct {
    uint16_t segment_limit;
    uint16_t base_low;
    uint8_t base_middle;
    uint8_t access;
    uint8_t granularity;
    uint8_t base_high;
} __attribute__ ((packed)) gdt_entry_t;

static gdt_entry_t gdt[5];
gdt_descriptor_t gdt_ptr;

void set_gdt_entry(int i, uint32_t base, uint32_t limit, uint8_t access, uint8_t granularity) {
    gdt_entry_t *entry = &gdt[i/8];

    entry->segment_limit = limit & 0xffff;
    entry->base_low = base & 0xffff;
    entry->base_middle = (base >> 16) & 0xff;
    entry->access = access;
    entry->granularity = (limit >> 16) & 0x0f;
    entry->granularity = entry->granularity | (granularity & 0xf0);
    entry->base_high = (base >> 24 & 0xff);
}

void init_gdt() {
    gdt_ptr.size = sizeof(gdt) - 1;
    gdt_ptr.offset = (uint32_t) gdt;

    set_gdt_entry(NULL, 0, 0, 0, 0);
    set_gdt_entry(KERNEL_CODE, 0, 0xffffffff, 0x9a, 0xcf);
    set_gdt_entry(KERNEL_DATA, 0, 0xffffffff, 0x92, 0xcf);
    set_gdt_entry(USER_CODE, 0, 0xffffffff, 0xfa, 0xcf);
    set_gdt_entry(USER_DATA, 0, 0xffffffff, 0xf2, 0xcf);

    load_gdt((uint32_t) &gdt_ptr, KERNEL_CODE, KERNEL_DATA);
}
