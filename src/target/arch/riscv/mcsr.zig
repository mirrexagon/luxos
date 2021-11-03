const std = @import("std");

const Csr = @import("../riscv.zig").Csr;

pub const misa = Csr(0x301, packed struct {
    extensions: packed struct {
        a: bool,
        b: bool,
        c: bool,
        d: bool,
        e: bool,
        f: bool,
        g: bool,
        h: bool,
        i: bool,
        j: bool,
        k: bool,
        l: bool,
        m: bool,
        n: bool,
        o: bool,
        p: bool,
        q: bool,
        r: bool,
        s: bool,
        t: bool,
        u: bool,
        v: bool,
        w: bool,
        x: bool,
        y: bool,
        z: bool,
    },
    _reserved_26: u4, // TODO: This is bigger in RV64, dynamically determine the size of this.
    mxl: enum(u2) {
        _reserved = 0,
        xlen32 = 1,
        xlen64 = 2,
        xlen128 = 3,
    },
});
