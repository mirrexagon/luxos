//! PRCI (Power, Reset, Clock, Interrupt) is an umbrella term for platform
//! non-AON memory-mapped control and status registers controlling component
//! power states, resets, clock selection, and low-level interrupts, hence the
//! name.
//! - FE310-G002 manual v1p1, section 6.2

const Register = @import("../../../register.zig").Register;

const prci_base_address = 0x1000_8000;

/// An internal trimmable high-frequency ring oscillator (HFROSC) is used to
/// provide the default clock after reset, and can be used to allow operation
/// without an external high-frequency crystal or the PLL.
/// The oscillator is controlled by the hfrosccfg register.
pub const hfrosccfg = Register(u32, hfrosccfg_struct, hfrosccfg_struct).new(prci_base_address + 0x0);

/// An external high-frequency 16 MHz crystal oscillator (HFXOSC) can be used to
/// provide a precise clock source.
/// The HFXOSC is controlled via the memory-mapped hfxosccfg register.
pub const hfxosccfg = Register(u32, hfxosccfg_struct, hfxosccfg_struct).new(prci_base_address + 0x4);

pub const pllcfg = Register(u32, pllcfg_struct, pllcfg_struct).new(prci_base_address + 0x8);

const hfrosccfg_struct = packed struct {
    /// Ring Oscillator Divider Register (RW)
    hfroscdiv: u6,
    _reserved_6: u10,
    /// Ring Oscillator Trim Register (RW)
    hfrosctrim: u5,
    _reserved_21: u9,
    /// Ring Oscillator Enable (RW)
    hfroscen: bool,
    /// Ring Oscillator Ready (RO)
    hfroscrdy: bool,
};

const hfxosccfg_struct = packed struct {
    _reserved_0: u29,
    /// Crystal Oscillator Enable (RW)
    hfxoscen: bool,
    /// Crystal Oscillator Ready (RO)
    hfxoscrdy: bool,
};

const pllcfg_struct = packed struct {
    /// PLL R Value (RW)
    pllr: u3,
    _reserved_3: u1,
    /// PLL F Value (RW)
    pllf: u6,
    /// PLL Q Value (RW)
    pllq: u2,
    _reserved_12: u4,
    /// PLL Select (RW)
    pllsel: bool,
    /// PLL Reference Select (RW)
    pllrefsel: bool,
    /// PLL Bypass (RW)
    pllbypass: bool,
    _reserved_19: u12,
    /// PLL Lock (RO)
    plllock: bool,
};
