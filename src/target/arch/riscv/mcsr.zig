const std = @import("std");

const riscv = @import("../riscv.zig");
const Csr = riscv.Csr;

// Machine Information Registers
pub const mvendorid = Csr(0xF11);
pub const marchid = Csr(0xF12);
pub const mimpid = Csr(0xF13);
pub const mhartid = Csr(0xF14);

// Machine Trap Setup
pub const mstatus = Csr(0x300);

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
    _reserved_26: riscv.unsignedIntegerWithSize(riscv.xlen - 28),
    mxl: enum(u2) {
        unknown = 0,
        xlen32 = 1,
        xlen64 = 2,
        xlen128 = 3,
    },
});

pub const medeleg = Csr(0x302);
pub const mideleg = Csr(0x303);
pub const mie = Csr(0x304);
pub const mtvec = Csr(0x305);
pub const mcounteren = Csr(0x306);

// Machine Trap Handling
pub const mscratch = Csr(0x340);
pub const mepc = Csr(0x341);
pub const mcause = Csr(0x342);
pub const mtval = Csr(0x343);
pub const mip = Csr(0x344);
