#ifndef ARCH_VGA_H
#define ARCH_VGA_H

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

#include <kernel/utils.h>

void putpixel(uint16_t x, uint16_t y, uint8_t fg);
void set_row(uint16_t y, uint8_t bg);

#endif
