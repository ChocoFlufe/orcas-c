#include <arch/vga.h>

#define VMEM_LOC 0xa0000

void putpixel(uint16_t x, uint16_t y, uint8_t fg) {
    uint8_t *v_mem = (uint8_t *)VMEM_LOC + SCREEN_WIDTH * y + x;
    *v_mem = fg;
}

void set_row(uint16_t y, uint8_t bg) {
    uint8_t *v_mem = (uint8_t *)VMEM_LOC + SCREEN_WIDTH * y;
    for (int i = 0; i < SCREEN_WIDTH; i++)
        *v_mem++ = bg;
}
