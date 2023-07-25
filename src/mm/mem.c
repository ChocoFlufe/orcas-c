#include <mm/mem.h>

#define KHEAP_END 0x7ffff
#define ALIGN 4

extern uint8_t _end;

typedef struct block_t {
    size_t size;
    uint8_t free;
    struct block_t *next;
} block_t;

block_t *kheap_start;
uint8_t *kheap_end;
spinlock_t kheap_lock;

void *sbrk(uint32_t incr) {
    if (kheap_end + incr > KHEAP_END)
        return (void *) -1;
    uint8_t* tmp = kheap_end;
    kheap_end += incr;
    return (void*) tmp;
}

void init_kheap() {
    kheap_start = NULL;
    kheap_end = &_end;
    init_spinlock(&kheap_lock);
}

void *kmalloc(size_t size) {
    lock(&kheap_lock);

    block_t* curr_block = kheap_start;
    block_t* prev_block = NULL;
    size = (size + ALIGN - 1) & ~(ALIGN - 1);

    while (curr_block) {
        if (curr_block->free && curr_block->size >= size) {
            curr_block->free = false;
            if (curr_block->size > size + sizeof(block_t)) {
                // Split block
                block_t *new_block = (void*) curr_block + size + sizeof(block_t);
                new_block->size = curr_block->size - size - sizeof(block_t);
                new_block->next = curr_block->next;
                new_block->free = true;
                curr_block->size = size;
                curr_block->next = new_block;
            }
            unlock(&kheap_lock);
            return (void*)(curr_block + 1);
        }

        prev_block = curr_block;
        curr_block = curr_block->next;
    }

    // Extend heap
    block_t* new_block = sbrk(sizeof(block_t) + size);
    if (new_block == (void*) -1) {
        unlock(&kheap_lock);
        return NULL;
    }

    new_block->size = size;
    new_block->free = false;
    new_block->next = NULL;

    if (prev_block)
        prev_block->next = new_block;
    else
        kheap_start = new_block;

    unlock(&kheap_lock);
    return (void*)(new_block + 1);
}

void *kcalloc(size_t n, size_t size) {
    void *ptr = kmalloc(n * size);
    memset(ptr, 0, n * size);

    return ptr;
}

void *krealloc(void *ptr, size_t size) {
    block_t *block = (block_t*) ptr - 1;
    void *new_ptr;

    if(!ptr)
        return kmalloc(size);

    if(!size) {
        kfree(ptr);
        return NULL;
    }

    if(block->size >= size)
        return ptr;

    new_ptr = kmalloc(size);
    memcpy(new_ptr, ptr, block->size);
    kfree(ptr);

    return new_ptr;
}

void kfree(void *ptr) {
    if (!ptr) {
        return;
    }

    lock(&kheap_lock);

    block_t* block = (block_t*) ptr - 1;
    block->free = true;

    // Coalesce with next block
    if(block->next && block->next->free) {
        block->size += block->next->size + sizeof(struct block_t);
        block->next = block->next->next;
    }

    // Coalesce with previous block
    if(block->next && block->next->free) {
        block->next->size += block->size + sizeof(struct block_t);
        block->next->next = block->next;
    }

    unlock(&kheap_lock);
}

