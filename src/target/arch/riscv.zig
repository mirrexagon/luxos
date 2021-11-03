pub const Csr = @import("riscv/csr.zig").Csr;

pub const mcsr = @import("riscv/mcsr.zig");
pub const scsr = @import("riscv/scsr.zig");
pub const ucsr = @import("riscv/ucsr.zig");

const std = @import("std");

pub const xlen = @bitSizeOf(usize);

pub fn unsignedIntegerWithSize(bits: u16) type {
    return @Type(.{ .Int = .{ .signedness = .unsigned, .bits = bits } });
}
