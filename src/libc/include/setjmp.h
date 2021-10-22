#pragma once

// long is the same size as a register.
// https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/097e4911a00b2d0d41dae9cf3b7ff7ebeebca2b3/riscv-cc.adoc#cc-type-sizes-and-alignments
typedef struct {
  // Return address for setjmp() invocation.
  long ra;

  // Stack pointer.
  long sp;

  // Callee-saved integer registers.
  long regs[12];

#if defined(__riscv_float_abi_double)
  // Callee-saved floating-point registers.
  double fpregs[12];
#elif !defined(__riscv_float_abi_soft)
#error "Defined float length not supported"
#endif

} jmp_buf[1];

int setjmp(jmp_buf env);
_Noreturn void longjmp(jmp_buf env, int status);
