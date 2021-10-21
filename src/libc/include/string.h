#pragma once

#include <stddef.h>

int memcmp(const void *lhs, const void *rhs, size_t count);
void *memcpy(void *restrict dest, const void *restrict src, size_t count);

size_t strlen(const char *s);
char *strcpy(char *restrict dest, const char *restrict src);
size_t strspn(const char *s1, const char *s2);
char *strchr(const char *str, int ch);
int strcmp(const char *lhs, const char *rhs);
char *strpbrk(const char *dest, const char *breakset);
int strcoll(const char *lhs, const char *rhs);
