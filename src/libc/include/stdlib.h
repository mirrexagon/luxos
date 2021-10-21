#pragma once

#include <stddef.h>

_Noreturn void abort(void);

int abs(int n);
double strtod(const char *restrict str, char **restrict str_end);
