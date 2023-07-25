#include <cpu/timer.h>

uint32_t tick;

void timer_callback(registers_t *regs) {
    tick++;
}

void init_timer(uint32_t hz) {
    tick = 0;

    register_intr_handler(32, timer_callback);
    /* Get the PIT value: hardware clock at 1193180 Hz */
    uint32_t divisor = 1193180 / hz;
    /* Send the command */
    outb(0x43, 0x36);
    outb(0x40, divisor & 0xff);
    outb(0x40, (divisor >> 8) & 0xff);
}

void sleep_tick(uint32_t ticks) {
    uint32_t start = tick;
    while (tick < start + ticks){}
    return;
}
