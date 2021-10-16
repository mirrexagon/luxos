//! PRCI (Power, Reset, Clock, Interrupt) is an umbrella term for platform
//! non-AON memory-mapped control and status registers controlling component
//! power states, resets, clock selection, and low-level interrupts, hence the
//! name.
//! - FE310-G002 manual v1p1, section 6.2

// Note: The manual lists a procmoncfg register but does not describe it.
// https://forums.sifive.com/t/fe310-g002-v1p0-manual-errata/4751

const Register = @import("../../../register.zig").Register;

pub fn useExternalCrystalOscillator() void {
    hfrosccfg.modify(.{
        .hfroscen = true,
    });

    // Set the PLL to pass through the external clock.
    pllcfg.modify(.{
        .pllbypass = true,
        .pllrefsel = .hfxosc,
    });

    // Switch to running the main high-frequency clock from the output of the PLL.
    // Since the PLL is bypassed and is running from the external oscillator,
    // this means the main high-frequency clock is running "directly" from the
    // 16 MHz external oscillator.
    pllcfg.modify(.{
        .pllsel = .pll,
    });

    // Now we can disable the internal Oscillator.
    hfrosccfg.modify(.{
        .hfroscen = false,
    });
}

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

/// The PLL generates a high-frequency clock by multiplying a mid-frequency
/// reference source clock, either the HFROSC or the HFXOSC. The input frequency
/// to the PLL can be in the range 6–48 MHz. The PLL can generate output
/// clock frequencies in the range 48–384 MHz.
/// The PLL is controlled by a memory-mapped read-write pllcfg register in the
/// PRCI address space.
pub const pllcfg = Register(u32, pllcfg_struct, pllcfg_struct).new(prci_base_address + 0x8);

/// The plloutdiv register controls a clock divider that divides the output of the PLL.
pub const plloutdiv = Register(u32, plloutdiv_struct, plloutdiv_struct).new(prci_base_address + 0xC);

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
    /// Selects which clock source drives the hfclk (main high-frequency clock
    /// that drives the CPU clock and others).
    pllsel: enum(u1) {
        /// Internal oscillator.
        hfrosc = 0,
        /// The output of the PLL.
        pll = 1,
    },
    /// PLL Reference Select (RW)
    /// Selects the clock source that drives the PLL.
    pllrefsel: enum(u1) {
        /// Internal oscillator.
        hfrosc,
        /// External oscillator.
        hfxosc,
    },
    /// PLL Bypass (RW)
    pllbypass: bool,
    _reserved_19: u12,
    /// PLL Lock (RO)
    plllock: bool,
};

const plloutdiv_struct = packed struct {
    /// PLL Final Divider Value (RW)
    plloutdiv: u6,
    _reserved_6: u2,
    /// PLL Final Divide By 1 (RW)
    plloutdivby1: bool,
    _reserved_9: u23,
};
