const prci = @import("target/soc/fe310-g002/prci.zig");
const gpio = @import("target/soc/fe310-g002/gpio.zig");
const uart = @import("target/soc/fe310-g002/uart.zig");

pub fn kmain() noreturn {
    prci.useExternalCrystalOscillator();
    gpio.setupUart0Gpio();

    uart.Uart0.setBaudRate();
    uart.Uart0.enableTx();

    for ("This is Luxos!\r\n") |c| {
        uart.Uart0.writeByte(c);
    }

    while (true) {}
}
