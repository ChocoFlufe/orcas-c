#include <cpu/gdt.h>
#include <cpu/idt.h>
#include <cpu/irq.h>
#include <cpu/isr.h>
#include <cpu/pic.h>
#include <cpu/timer.h>

#include <drivers/screen.h>

#include <mm/mem.h>

#include <kernel/utils.h>

extern uint8_t _bss_start, _bss_end;

void kmain(void) {
    bzero(&_bss_start, &_bss_end - &_bss_start);

    init_gdt();
    // Interrupts
    remap_pic();
    init_idt();
    load_isr();
    load_irq();

    init_timer(50);

    init_kheap();

    clear_screen();

    for (;;) {
        asm volatile("hlt");
    }
}
