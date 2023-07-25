#ifndef CPU_TIMER_H
#define CPU_TIMER_H

#include <cpu/irq.h>
#include <kernel/utils.h>

void init_timer(uint32_t freq);
void sleep_tick(uint32_t ticks);

#endif
