#include <stdint.h>
#include <stdlib.h>

double mean(double *values, uint64_t n);
double stddev(double *values, uint64_t n);

struct Array;

struct Array *array_init(double *, uint64_t);
double array_mean(struct Array *);
double array_stddev(struct Array *);
