//! PRCI (Power, Reset, Clock, Interrupt) is an umbrella term for platform
//! non-AON memory- mapped control and status registers controlling component
//! power states, resets, clock selection, and low-level interrupts, hence the
//! name.
//!
//! - FE310-G002 manual v1p5, section 6.2

// Note: The manual lists a procmoncfg register but does not describe it.
// https://forums.sifive.com/t/fe310-g002-v1p0-manual-errata/4751

// Notes:
// - 320 MHz may not be achievable after the chip warms up, 288 MHz might be more stable: https://forums.sifive.com/t/fe310-g002-clock-and-i-cache-performance/3187/9

const math = @import("std").math;

const Register = @import("../../../mmio_register.zig").Register;

const CRYSTAL_FREQUENCY_HZ = 16_000_000;

pub fn getHfclkFrequencyHz() u32 {
    const pllcfg_value = pllcfg.read();

    const pllInputFrequency = switch (pllcfg_value.pllrefsel) {
        .hfrosc => getHfroscFrequency(),
        .hfxosc => CRYSTAL_FREQUENCY_HZ,
    };

    return switch (pllcfg_value.pllsel) {
        .hfrosc => getHfroscFrequency(),
        .pll => if (pllcfg_value.pllbypass) {
            return pllInputFrequency;
        } else {
            const r: u32 = @intCast(u32, pllcfg_value.pllr) + 1;
            const f: u32 = 2 * (@intCast(u32, pllcfg_value.pllf) + 1);
            const q: u32 = math.powi(u32, 2, pllcfg_value.pllq) catch unreachable;

            return pllInputFrequency / r * f / q;
        },
    };
}

fn getHfroscFrequency() u32 {
    // Nominal value from manual, section 6.3
    return 14_400_000;
}

pub fn getCoreClkFrequencyHz() u32 {
    return getHfclkFrequencyHz();
}

pub fn getTlclkFrequencyHz() u32 {
    return getCoreClkFrequencyHz();
}

pub fn setupLfclk() void {}

pub fn setupHfclk() void {
    // Reset clock setup to hfrosc if required.
    if (pllcfg.read().pllsel == .pll) {
        hfrosccfg.modify(.{ .hfroscen = true });
        while (!hfrosccfg.read().hfroscrdy) {}

        pllcfg.modify(.{ .pllsel = .hfrosc });
    }

    // Now configure the PLL to use the external crystal and amplify to 320 MHz.
    if (!pllcfg.read().pllbypass) {
        // Disable PLL so we can configure it.
        pllcfg.modify(.{ .pllbypass = true });
    }

    hfxosccfg.modify(.{ .hfxoscen = true });
    while (!hfxosccfg.read().hfxoscrdy) {}

    // Disable PLL final output divider.
    plloutdiv.modify(.{
        .plloutdiv = 0,
        .plloutdivby1 = true,
    });

    // Set the PLL to turn the 16 MHz hfxosc into a 320 MHz signal.
    pllcfg.modify(.{
        .pllbypass = false,

        // hfxosc = 16 MHz
        .pllrefsel = .hfxosc,

        // R = 2
        // 16 MHz / 2 = 8 MHz
        .pllr = 1,

        // F = 80
        // 8 MHz * 80 = 640 MHz
        .pllf = 39,

        // Q = 2
        // 640 MHz / 2 = 320 MHz
        .pllq = 1,
    });

    // Wait 100 us for PLL to regain lock before checking plllock.
    // TODO: "I use 4 ticks of the 32 KHz low-frequency timer for this." - https://forums.sifive.com/t/something-i-learned-about-the-cpu-clock/2635

    while (!pllcfg.read().plllock) {}

    // Switch to running the main high-frequency clock (hfclk) from the output of the PLL.
    pllcfg.modify(.{ .pllsel = .pll });

    // Now we can disable the internal oscillator.
    hfrosccfg.modify(.{ .hfroscen = false });
}

const prci_base_address = 0x1000_8000;

/// An internal trimmable high-frequency ring oscillator (HFROSC) is used to
/// provide the default clock after reset, and can be used to allow operation
/// without an external high-frequency crystal or the PLL.
/// The oscillator is controlled by the hfrosccfg register.
pub const hfrosccfg = Register(u32, packed struct {
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
}).init(prci_base_address + 0x0);

/// An external high-frequency 16 MHz crystal oscillator (HFXOSC) can be used to
/// provide a precise clock source.
/// The HFXOSC is controlled via the memory-mapped hfxosccfg register.
pub const hfxosccfg = Register(u32, packed struct {
    _reserved_0: u30,
    /// Crystal Oscillator Enable (RW)
    hfxoscen: bool,
    /// Crystal Oscillator Ready (RO)
    hfxoscrdy: bool,
}).init(prci_base_address + 0x4);

/// The PLL generates a high-frequency clock by multiplying a mid-frequency
/// reference source clock, either the HFROSC or the HFXOSC. The input frequency
/// to the PLL can be in the range 6–48 MHz. The PLL can generate output
/// clock frequencies in the range 48–384 MHz.
/// The PLL is controlled by a memory-mapped read-write pllcfg register in the
/// PRCI address space.
pub const pllcfg = Register(u32, packed struct {
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
        hfrosc = 0,
        /// External oscillator.
        hfxosc = 1,
    },
    /// PLL Bypass (RW)
    pllbypass: bool,
    _reserved_19: u12,
    /// PLL Lock (RO)
    plllock: bool,
}).init(prci_base_address + 0x8);

/// The plloutdiv register controls a clock divider that divides the output of the PLL.
pub const plloutdiv = Register(u32, packed struct {
    /// PLL Final Divider Value (RW)
    plloutdiv: u6,
    _reserved_6: u2,
    /// PLL Final Divide By 1 (RW)
    plloutdivby1: bool,
    _reserved_9: u23,
}).init(prci_base_address + 0xC);
