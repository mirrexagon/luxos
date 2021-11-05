const std = @import("std");

const txdata = packed struct {
    /// Transmit data (RW)
    data: u8,
    _reserved_8: u23,
    /// Transmit FIFO full (RO)
    full: bool = false,
};

const txdata_passes = packed struct {
    /// Transmit data (RW)
    data: u9, // Changed to u9
    _reserved_8: u22, // Changed to u22
    /// Transmit FIFO full (RO)
    full: bool = false,
};

const mstatus = packed struct {
    uie: bool,
    sie: bool,
    _reserved_2: bool,
    mie: bool,
    upie: bool,
    spie: bool,
    _reserved_6: bool,
    mpie: bool,
    spp: u1,
    _reserved_9: u2,
    mpp: u2,
    fs: u2,
    xs: u2,
    mprv: bool,
    sum: bool,
    mxr: bool,
    tvm: bool,
    tw: bool,
    tsr: bool,
    _reserved_23: u8,
    sd: bool,
};

const register_size_bits = 32;
const register_size_bytes = register_size_bits / 8;

test "txdata size correct but fails" {
    try std.testing.expectEqual(register_size_bits, @bitSizeOf(txdata));
    try std.testing.expectEqual(register_size_bytes, @sizeOf(txdata));
}

test "txdata size adjusted to pass" {
    try std.testing.expectEqual(register_size_bits, @bitSizeOf(txdata_passes));
    try std.testing.expectEqual(register_size_bytes, @sizeOf(txdata_passes));
}

test "mstatus correct but fails" {
    try std.testing.expectEqual(register_size_bits, @bitSizeOf(mstatus));
    try std.testing.expectEqual(register_size_bytes, @sizeOf(mstatus));
}
