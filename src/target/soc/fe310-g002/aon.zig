//! The FE310-G002 supports an always-on (AON) domain that includes real-time
//! counter, a watchdog timer, backup registers, low frequency clocking, and
//! reset and power-management circuitry for the rest of the system.
//!
//! - FE310-G002 manual v1p5, chapter 13

const Register = @import("../../../mmio_register.zig").Register;

const aon_base_address = 0x1000_0000;

pub const lfrosccfg = Register(u32, packed struct {
    /// Ring Oscillator Divider Register (RW)
    lfroscdiv: u6,
    _reserved_6: u10,
    /// Ring Oscillator Trim Register (RW)
    lfrosctrim: u5,
    _reserved_21: u9,
    /// Ring Oscillator Enable (RW)
    lfroscen: bool,
    /// Ring Oscillator Ready (RO)
    lfroscrdy: bool,
}).init(aon_base_address + 0x070);

pub const lfclkmux = Register(u32, packed struct {
    /// Low Frequency Clock Source Selector (RW)
    /// Names of options from https://github.com/sifive/freedom-e-sdk/blob/aed2cd215c88b489c2598e3a27394abe3c556558/bsp/sifive-hifive1/design.svd#L395
    lfextclk_sel: enum(u1) {
        internal = 0,
        external = 1,
    },
    _reserved_1: u30,
    /// Setting of the aon_lfclksel pin (RO)
    /// Names of options from https://github.com/sifive/freedom-e-sdk/blob/aed2cd215c88b489c2598e3a27394abe3c556558/bsp/sifive-hifive1/design.svd#L418
    lfextclk_mux_status: enum(u1) {
        external = 0,
        lftextclk_sel = 1,
    },
}).init(aon_base_address + 0x07C);
