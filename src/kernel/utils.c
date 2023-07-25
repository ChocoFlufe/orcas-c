#include <kernel/utils.h>

void *memset(void *dst, int val, size_t len) {
    if (!dst)
        return NULL;
    uint8_t *ptr = (uint8_t *) dst;
    while (len--)
        *ptr++ = val;
    return dst;
}

void *memcpy(void *dst, const void *src, size_t len) {
    if (!src || !dst)
        return NULL;
    uint8_t *ptr_d = dst;
    const uint8_t *ptr_s = src;
    while (len--)
        *ptr_d++ = *ptr_s++;
    return dst;
}

void *memmove(void *dst, void *src, size_t count) {
    if (!src || !dst)
        return NULL;
    if (dst > src)
        return memcpy(dst, src, count);
    uint8_t *ptr_d = dst;
    const uint8_t *ptr_s = src;
    while (count--)
        ptr_d[count] = ptr_s[count];
    return dst;
}

int memcmp(void *str1, void *str2, int count) {
    uint8_t *s1 = str1;
    uint8_t *s2 = str2;
    if (s1 == s2)
        return 0;
    while (count--) {
        if (*s1++ != *s2++)
            return s1[-1] < s2[-1] ? -1 : 1;
    }
    return 0;
}

void bzero(void *dst, size_t count) {
    memset(dst, 0, count);
}

void init_spinlock(spinlock_t *lock) {
    lock->lock = false;
}

void lock(spinlock_t *lock) {
    while(!__sync_bool_compare_and_swap(&lock->lock, false, true));
}

void unlock(spinlock_t *lock) {
    lock->lock = 0;
}

char* itoa(int num, string str, int base) {
    int i = 0;
    int negative = false;

    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }

    if (num < 0 && base == 10) {
        negative = true;
        num = -num;
    }

    while (num != 0) {
        int rem = num % base;
        str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        num = num / base;
    }

    if (negative)
        str[i++] = '-';

    str[i] = '\0';

    reverse(str, i);

    return str;
}

void reverse(string str, const int len) {
    char tmp;

    for (int i = 0; i < len / 2; i++) {
        tmp = str[i];
        str[i] = str[len - i - 1];
        str[len - i - 1] = tmp;
    }
}
