#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 100000000
#define RMAX 92233720368

static uint64_t sum_list(uint64_t *list, uint64_t n) {
    uint64_t total = 0;
    for (uint64_t i = 0; i < n; i++) {
        total += list[i];
    }
    return total;
}

static uint64_t tns() {
    struct timespec time_spec;
    (void)clock_gettime(CLOCK_MONOTONIC, &time_spec);
    return (uint64_t)time_spec.tv_sec * 1e9 + (uint64_t)time_spec.tv_nsec;
}

int main(void) {
    srand(time(0));
    static uint64_t ns[N];
    for (uint64_t i = 0; i < N; i++) {
        ns[i] = (uint64_t)(((double)rand() / ((double)RAND_MAX + 1.)) *
                           (RMAX + 1.));
    }
    uint64_t start = tns();
    uint64_t s = sum_list(ns, N);
    uint64_t end = tns();
    printf("c %lu %luus\n", s, (uint64_t)((double)(end - start) / 1e3));
    return 0;
}
