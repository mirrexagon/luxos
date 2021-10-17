#pragma once

typedef int jmp_buf[9];

int setjmp(jmp_buf env);
_Noreturn void longjmp(jmp_buf env, int status);
