const prci = @import("target/soc/fe310-g002/prci.zig");

pub fn kmain() noreturn {
    prci.useExternalCrystalOscillator();

    while (true) {}
}
