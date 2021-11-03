const std = @import("std");

// Reference for implementation:
// https://danielmangum.com/posts/non-local-jumps-riscv/

const c = @cImport({
    @cInclude("setjmp.h");
});

export fn setjmp(env: *c.jmp_buf) c_int {
    // Note:
    // - This implementation is 32-bit only: sw stores 32 bits and offset
    // between fields is 4 bytes.
    // - This implementation assumes that there are no floating-point registers.
    //
    // TODO: Update for 64-bit and float/double when required.
    // Querying CPU info: @import("builtin").target.cpu.arch, etc.
    comptime {
        std.debug.assert(@import("builtin").cpu.arch == .riscv32);
    }

    // Store the required registers to env.
    // jmp_buf is basically an array of register-sized values.
    // We store the contents of all the registers we need to there.
    // a0 is the pointer to the jmp_buf.
    _ = asm volatile (
        \\sw ra, 0(a0)
        \\sw sp, 4(a0)
        \\sw s0, 8(a0)
        \\sw s1, 12(a0)
        \\sw s2, 16(a0)
        \\sw s3, 20(a0)
        \\sw s4, 24(a0)
        \\sw s5, 28(a0)
        \\sw s6, 32(a0)
        \\sw s7, 36(a0)
        \\sw s8, 40(a0)
        \\sw s9, 44(a0)
        \\sw s10, 48(a0)
        \\sw s11, 52(a0)
        :
        : [env] "{a0}" (env),
        : "memory"
    );

    // 0 is returned when initially calling setjmp().
    // when longjmp() jumps to the caller of setjmp(), it sets the return value
    // register to the status value passed to longjmp().
    return 0;
}

export fn longjmp(env: *c.jmp_buf, status: c_int) noreturn {
    // Load the required registers from env, set the return value to status (or
    // 1 if it is 0), then perform a return.
    // The return will use the return address we put in ra, which is the return
    // address for the original setjmp() call.

    _ = asm volatile (
        \\lw ra, 0(a0)
        \\lw sp, 4(a0)
        \\lw s0, 8(a0)
        \\lw s1, 12(a0)
        \\lw s2, 16(a0)
        \\lw s3, 20(a0)
        \\lw s4, 24(a0)
        \\lw s5, 28(a0)
        \\lw s6, 32(a0)
        \\lw s7, 36(a0)
        \\lw s8, 40(a0)
        \\lw s9, 44(a0)
        \\lw s10, 48(a0)
        \\lw s11, 52(a0)
        \\seqz a0, a1
        \\add a0, a0, a1
        \\ret
        :
        : [env] "{a0}" (env),
          [status] "{a1}" (status),
        : "ra", "sp", "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11"
    );

    unreachable;
}
