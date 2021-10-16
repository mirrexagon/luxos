const prci = @import("target/soc/fe310-g002/prci.zig");
const gpio = @import("target/soc/fe310-g002/gpio.zig");

pub fn kmain() noreturn {
    prci.useExternalCrystalOscillator();
    gpio.setupUart0Gpio();

    while (true) {}
}
