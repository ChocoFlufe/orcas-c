#include <drivers/screen.h>

void putchar(char c, uint16_t x, uint16_t y, uint8_t fg) {
    assert(c >= 0);
    uint8_t *glyph = FONT[(size_t) c];

    for (uint8_t cx = 0; cx < FONT_WIDTH; cx++){
        for (uint8_t cy = 0; cy < FONT_HEIGHT; cy++){
            if (glyph[cx] & 1 << cy) {
                putpixel(x + cx, y + cy, fg);
            }
        }
    }
}

void puts(char *s, uint16_t x, uint16_t y, uint8_t fg) {
    char c;
    while ((c = *s++) != 0) {
        putchar(c, x, y, fg);
        x += FONT_WIDTH;
    }

}

void clear_screen() {
    for (int i = 0; i < SCREEN_HEIGHT; i++)
        set_row(i, 0x12);
}
