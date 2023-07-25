#include <kernel/panic.h>

void panic(void) {
    asm volatile("cli");
    asm volatile("hlt");
}
