const std = @import("std");
const mem = std.mem;

const fe310 = @import("target/soc/fe310-g002.zig");
const prci = fe310.prci;
const gpio = fe310.gpio;
const uart = fe310.uart;

const lua = @import("lua.zig");

pub fn kmain() noreturn {
    prci.useExternalCrystalOscillator();
    gpio.setupUart0Gpio();

    uart.Uart0.setBaudRate();
    uart.Uart0.enableTx();

    for ("Welcome to Luxos!\r\n") |c| {
        uart.Uart0.writeByte(c);
    }

    _ = lua.new(null);

    while (true) {}
}
