const std = @import("std");
const mem = std.mem;

const expectEqual = @import("testutil.zig").expectEqual;

// Note: Often, C return is non-const, but const is here to satisfy Zig.
//
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
    const abccd = "abccd";

    try expectEqual(null, strchr(abccd, 'x'));
    try expectEqual(&abccd[0], strchr(abccd, 'a'));
    try expectEqual(&abccd[4], strchr(abccd, 'd'));
    try expectEqual(&abccd[5], strchr(abccd, '\x00'));
    try expectEqual(&abccd[2], strchr(abccd, 'c'));
}

export fn strpbrk(dest: [*:0]const u8, breakset: [*:0]const u8) ?*const u8 {
    _ = dest;
    _ = breakset;
    return null;
}

test "strpbrk" {
    const abcde = "abcde";
    const abcdx = "abcdx";

    try expectEqual(null, strpbrk(abcde, "x"));
    try expectEqual(null, strpbrk(abcde, "xyz"));
    try expectEqual(&abcdx[4], strpbrk(abcdx, "x"));
    try expectEqual(&abcdx[4], strpbrk(abcdx, "xyz"));
    try expectEqual(&abcdx[4], strpbrk(abcdx, "zyx"));
    try expectEqual(&abcde[0], strpbrk(abcde, "a"));
    try expectEqual(&abcde[0], strpbrk(abcde, "abc"));
    try expectEqual(&abcde[0], strpbrk(abcde, "cba"));
}
