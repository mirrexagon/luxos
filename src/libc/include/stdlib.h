#pragma once

#include <stddef.h>

_Noreturn void abort(void);

double strtod(const char *restrict str, char **restrict str_end);
