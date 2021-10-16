//! The GPIO controller is a peripheral device mapped in the internal memory
//! map. It is responsible for low-level configuration of actual GPIO pads
//! on the device (direction, pull up-enable, and drive value ), as well as
//! selecting between various sources of the controls for these signals. The
//! GPIO controller allows separate configuration of each of ngpio (32) GPIO
//! bits.
//!
//! - FE310-G002 manual v1p1, Chapter 17

pub fn setupUart0Gpio() void {
    setGpioRegister(16, iof_sel, 0);
    setGpioRegister(17, iof_sel, 0);

    setGpioRegister(16, iof_en, 1);
    setGpioRegister(17, iof_en, 1);
}

// Each GPIO control register is 32 bits wide and controls a single aspect of
// the GPIO pins, each bit corresponding to one pin.

const gpio_base_address = 0x1001_2000;

// GPIO register offsets.
const input_val = 0x00; // Pin value
const input_en = 0x04; // Pin input enable
const output_en = 0x08; // Pin output enable
const output_val = 0x0C; // Output value
const pue = 0x10; // Internal pull-up enable
const ds = 0x14; // Pin drive strength
const rise_ie = 0x18; // Rise interrupt enable
const rise_ip = 0x1C; // Rise interrupt pending
const fall_ie = 0x20; // Fall interrupt enable
const fall_ip = 0x24; // Fall interrupt pending
const high_ie = 0x28; // High interrupt enable
const high_ip = 0x2C; // High interrupt pending
const low_ie = 0x30; // Low interrupt enable
const low_ip = 0x34; // Low interrupt pending
const iof_en = 0x38; // I/O function enable
const iof_sel = 0x3C; // I/O function select
const out_xor = 0x40; // Output XOR (invert)
const passthru_high_ie = 0x44; // Pass-through active-high interrupt enable
const passthru_low_ie = 0x48; // Pass-through active-low interrupt enable

fn setGpioRegister(gpio: u5, register_offset: usize, new_value: bool) void {
    const ptr = @intToPtr(*volatile u32, gpio_base_address + register_offset);

    var value = ptr.*;

    if (new_value) {
        value |= (1 << gpio);
    } else {
        value &= ~(1 << gpio);
    }

    ptr.* = value;
}
