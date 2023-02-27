//! The CLINT block holds memory-mapped control and status registers associated
//! with software and timer interrupts. The FE310-G002 CLINT complies with The
//! RISC‑V Instruction Set Manual, Volume II: Privileged Architecture, Version
//! 1.10.
//!
//! - FE310-G002 manual v1p5, chapter 9

const Register = @import("../../../mmio_register.zig").Register;

const clint_base_address = 0x0200_0000;

pub const msip_hart0 = Register(u32, packed struct {
    /// MSIP bit of the hart's `mip` CSR (RW)
    msip: bool,
    _reserved_1: u31,
}).init(clint_base_address + 0x0);

pub const mtimecmp_hart0 = Register(u64, u64).init(clint_base_address + 0x4000);

pub const mtime = Register(u64, u64).init(clint_base_address + 0xbff8);
