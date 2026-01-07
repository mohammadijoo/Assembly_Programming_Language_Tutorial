/* src/test_lib.c */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

uint64_t add_u64(uint64_t a, uint64_t b);
size_t strlen_asm(const char* s);

static void test_add(void) {
    struct { uint64_t a, b; } cases[] = {
        {0, 0},
        {1, 2},
        {0xffffffffffffffffULL, 1},
        {0x1122334455667788ULL, 0x0101010101010101ULL},
    };
    for (size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        uint64_t got = add_u64(cases[i].a, cases[i].b);
        uint64_t ref = cases[i].a + cases[i].b;
        if (got != ref) {
            printf("add_u64 mismatch at %zu: got=%llx ref=%llx\n",
                   i, (unsigned long long)got, (unsigned long long)ref);
        }
    }
}

static void test_strlen(void) {
    const char* cases[] = {"", "A", "Hello", "abc\0def", "longer string..."};
    for (size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        size_t got = strlen_asm(cases[i]);
        size_t ref = strlen(cases[i]);
        if (got != ref) {
            printf("strlen_asm mismatch at %zu: got=%zu ref=%zu\n", i, got, ref);
        }
    }
}

int main(void) {
    test_add();
    test_strlen();
    puts("tests completed");
    return 0;
}
