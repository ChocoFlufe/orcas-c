#include <arch/vga.h>

void putpixel(uint16_t x, uint16_t y, uint8_t VGA_COLOR) {
    size_t *vmem = (size_t *)VIDEO_MEMORY_LOC + 320 * x + y;
    *vmem = VGA_COLOR;
}
