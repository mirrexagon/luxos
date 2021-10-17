#pragma once

#define NULL 0

typedef unsigned long size_t;
typedef long ptrdiff_t;

// https://github.com/DevSolar/pdclib/blob/b354e851195b555758e1c41df0fede3c11c2d179/platform/example/include/pdclib/_PDCLIB_config.h#L529
#define offsetof(type, member) ((size_t) & (((type *)0)->member))
