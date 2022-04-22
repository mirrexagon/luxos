#pragma once

void _libc_assert(const char* const condition_string, int condition);

#define assert(condition) _libc_assert(#condition, condition)
