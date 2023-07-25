#ifndef MM_MEM_H
#define MM_MEM_H

#include <kernel/utils.h>

void init_kheap();
void *kmalloc(size_t size);
void *kcalloc(size_t n, size_t size);
void *krealloc(void *ptr, size_t size);
void kfree(void *ptr);

#endif
