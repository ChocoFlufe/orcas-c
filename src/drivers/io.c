#include <drivers/io.h>

uint8_t inb(uint16_t port) {
    uint8_t res = 0;
    asm volatile("inb %%dx, %%al" : "=a" (res) : "d" (port));
    return res;
}

void outb(uint16_t port, uint8_t data) {
    asm volatile("outb %%al, %%dx" :: "a" (data), "d" (port));
}

uint16_t inw(uint16_t port) {
    uint16_t res = 0;
    asm volatile("inw %%dx, %%ax" : "=a" (res) : "d" (port));
    return res;
}

void outw(uint16_t port, uint16_t data) {
    asm volatile("outw %%ax, %%dx" :: "a" (data), "d" (port));
}
