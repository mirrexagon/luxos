const std = @import("std");
const mem = std.mem;
const testing = std.testing;

// Note: C return is non-const, but const is here to satisfy Zig.
export fn strchr(str: [*:0]const u8, ch: c_int) ?*const u8 {
    var i: usize = 0;
    while (str[i] != 0) : (i += 1) {
        if (str[i] == @intCast(u8, ch)) {
            return &str[i];
        }
    }

    if (ch == 0) {
        return &str[i];
    }

    return null;
}

test "strchr" {
    const abccd: [*:0]const u8 = "abccd";
    try testing.expectEqual(@as(?*const u8, null), strchr(abccd, 'x'));
    try testing.expectEqual(@as(?*const u8, &abccd[0]), strchr(abccd, 'a'));
    try testing.expectEqual(@as(?*const u8, &abccd[4]), strchr(abccd, 'd'));
    try testing.expectEqual(@as(?*const u8, &abccd[5]), strchr(abccd, '\x00'));
    try testing.expectEqual(@as(?*const u8, &abccd[2]), strchr(abccd, 'c'));
}
