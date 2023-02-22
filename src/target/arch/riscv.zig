pub const Csr = @import("riscv/csr.zig").Csr;

pub const mcsr = @import("riscv/mcsr.zig");
pub const scsr = @import("riscv/scsr.zig");
pub const ucsr = @import("riscv/ucsr.zig");

pub const xlen = @bitSizeOf(usize);
pub const arch = @import("builtin").cpu.arch;

pub fn unsignedIntegerWithSize(comptime bits: u16) type {
    return @Type(.{ .Int = .{ .signedness = .unsigned, .bits = bits } });
}
