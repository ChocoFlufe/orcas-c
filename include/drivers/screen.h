#ifndef DRIVERS_SCREEN_H
#define DRIVERS_SCREEN_H

#include <arch/vga.h>
#include <kernel/utils.h>

#include <fonts/BMplain.h>
// #include <fonts/basic.h>

// #define FONT BMplain

void putchar(char c, uint16_t x, uint16_t y, uint8_t fg);
void puts(char *s, uint16_t x, uint16_t y, uint8_t fg);
void clear_screen();

#endif
