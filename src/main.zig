const prci = @import("target/soc/fe310-g002/prci.zig");

pub fn kmain() noreturn {
    _ = prci.hfrosccfg.read();

    while (true) {}
}
