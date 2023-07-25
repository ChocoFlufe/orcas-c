#ifndef KERNEL_UTILS_H
#define KERNEL_UTILS_H

#include <kernel/panic.h>

#define true (1)
#define false (0)

#define NULL (0)

#define assert(expr) \
    if (!(expr))     \
        panic();

typedef char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

#ifdef __LP64__
    typedef uint64_t size_t;
    typedef uint64_t uintptr_t;
#else
    typedef uint32_t size_t;
    typedef uint32_t uintptr_t;
#endif

typedef char *string;

typedef struct {
    volatile uint8_t lock;
} spinlock_t;

void *memset(void *dst, int val, size_t len);
void *memcpy(void *dst, const void *src, size_t len);
void *memmove(void *dst, void *src, size_t count);
int memcmp(void *str1, void *str2, int count);
void bzero(void *dst, size_t count);

void init_spinlock(spinlock_t *lock);
void lock(spinlock_t *lock);
void unlock(spinlock_t *lock);

char* itoa(int num, string str, int base);
void reverse(string str, const int len);

#endif
