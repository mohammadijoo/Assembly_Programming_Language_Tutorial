/* src/main.c */
#include <stdio.h>
#include <stdint.h>

uint64_t add_u64(uint64_t a, uint64_t b);

int main(void) {
    uint64_t x = 0x1122334455667788ULL;
    uint64_t y = 0x0101010101010101ULL;
    printf("sum = 0x%llx\n", (unsigned long long)add_u64(x, y));
    return 0;
}
