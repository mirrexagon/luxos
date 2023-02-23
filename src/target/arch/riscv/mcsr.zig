const std = @import("std");

const riscv = @import("../riscv.zig");
const Csr = riscv.Csr;

// Machine Information Registers
pub const mvendorid = Csr(0xF11, packed struct { offset: u7, bank: u25, _reserved_32: riscv.unsignedIntegerWithSize(riscv.xlen - 32) });

pub const marchid = Csr(0xF12, riscv.unsignedIntegerWithSize(riscv.xlen));

pub const mimpid = Csr(0xF13, riscv.unsignedIntegerWithSize(riscv.xlen));

pub const mhartid = Csr(0xF14, riscv.unsignedIntegerWithSize(riscv.xlen));

// Machine Trap Setup
pub const mstatus = Csr(0x300, if (riscv.arch == .riscv32) packed struct {
    _reserved_0: bool,
    sie: bool,
    _reserved_2: bool,
    mie: bool,
    _reserved_4: bool,
    spie: bool,
    ube: bool,
    mpie: bool,
    spp: u1,
    vs: u2,
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
} else if (riscv.arch == .riscv64) packed struct {
    _reserved_0: bool,
    sie: bool,
    _reserved_2: bool,
    mie: bool,
    _reserved_4: bool,
    spie: bool,
    ube: bool,
    mpie: bool,
    spp: u1,
    vs: u2,
    mpp: u2,
    fs: u2,
    xs: u2,
    mprv: bool,
    sum: bool,
    mxr: bool,
    tvm: bool,
    tw: bool,
    tsr: bool,
    _reserved_23: u9,
    uxl: u2,
    sxl: u2,
    sbe: bool,
    mbe: bool,
    _reserved_38: u25,
    sd: bool,
} else @compileError("Unsupported architecture"));

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

pub const medeleg = Csr(0x302, usize);
pub const mideleg = Csr(0x303, usize);
pub const mie = Csr(0x304, usize);

pub const mtvec = Csr(0x305, packed struct {
    mode: enum(u2) {
        direct = 0,
        vectored = 1,
    },
    base: riscv.unsignedIntegerWithSize(riscv.xlen - 2),
});

//pub const mcounteren = Csr(0x306);

// Machine Trap Handling
pub const mscratch = Csr(0x340, usize);
pub const mepc = Csr(0x341, usize);

const interrupt_bit = 1 << riscv.xlen - 1;
pub const mcause = Csr(0x342, packed struct { code: enum(usize) {
    instruction_address_misaligned = 0,
    instruction_access_fault = 1,
    illegal_instruction = 2,
    breakpoint = 3,
    load_address_misaligned = 4,
    load_access_fault = 5,
    store_amo_address_misaligned = 6,
    store_amo_access_fault = 7,
    environment_call_from_u_mode = 8,
    environment_call_from_s_mode = 9,
    environment_call_from_m_mode = 11,
    instruction_page_faul = 12,
    load_page_fault = 13,
    store_amo_page_fault = 15,

    user_software_interrupt = 0 | interrupt_bit,
    supervisor_software_interrupt = 1 | interrupt_bit,
    machine_software_interrupt = 3 | interrupt_bit,
    user_timer_interrupt = 4 | interrupt_bit,
    supervisor_timer_interrupt = 5 | interrupt_bit,
    machine_timer_interrupt = 7 | interrupt_bit,
    user_external_interrupt = 8 | interrupt_bit,
    supervisor_external_interrupt = 9 | interrupt_bit,
    machine_external_interrupt = 11 | interrupt_bit,
} });

pub const mtval = Csr(0x343, usize);
pub const mip = Csr(0x344, usize);
