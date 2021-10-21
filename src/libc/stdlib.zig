const std = @import("std");

const expectEqual = @import("testutil.zig").expectEqual;

export fn abort() noreturn {
    // TODO: Panic
    while (true) {}
}

export fn abs(n: c_int) c_int {
    if (n < 0) {
        return -n;
    } else {
        return n;
    }
}

test "abs" {
    try expectEqual(10, abs(10));
    try expectEqual(10, abs(-10));
    try expectEqual(0, abs(0));
}
