const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const expectEqual = @import("testutil.zig").expectEqual;

// Note: Often, C return is non-const, but const is here to satisfy Zig.

export fn strchr(str: [*:0]const u8, ch: c_int) ?*const u8 {
    const span = mem.span(str);

    for (span) |src_ch, i| {
        if (src_ch == @intCast(u8, ch)) {
            return &str[i];
        }
    }

    if (ch == 0) {
        return &str[span.len];
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
    for (mem.span(dest)) |c, i| {
        if (strchr(breakset, c) != null) {
            return &dest[i];
        }
    }

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

export fn strlen(s: [*:0]const u8) usize {
    return mem.span(s).len;
}

test "strlen" {
    try expectEqual(5, strlen("abcde"));
    try expectEqual(0, strlen(""));
}

export fn strcmp(lhs: [*:0]const u8, rhs: [*:0]const u8) c_int {
    var i: usize = 0;

    while (lhs[i] != 0) : (i += 1) {
        if (lhs[i] != rhs[i]) {
            break;
        }
    }

    return @as(c_int, lhs[i]) - @as(c_int, rhs[i]);
}

test "strcmp" {
    const abcde = "abcde";
    const abcdx = "abcdx";
    const cmpabcde = "abcde";
    const cmpabcd_ = "abcd\xfc";
    const empty = "";

    try testing.expect(strcmp(abcde, cmpabcde) == 0);
    try testing.expect(strcmp(abcde, abcdx) < 0);
    try testing.expect(strcmp(abcdx, abcde) > 0);
    try testing.expect(strcmp(empty, abcde) < 0);
    try testing.expect(strcmp(abcde, empty) > 0);
    try testing.expect(strcmp(abcde, cmpabcd_) < 0);
}

export fn strcpy(dest: [*]u8, src: [*:0]const u8) [*]u8 {
    const src_span = mem.span(src);

    for (src_span) |c, i| {
        dest[i] = c;
    }

    // The loop doesn't seem to cover the terminating zero, so we copy it
    // explicitly here.
    dest[src_span.len] = src_span[src_span.len];

    return dest;
}

test "strcpy" {
    const abcde = "abcde";
    var buf = [_]u8{'x'} ** 6;
    var s = &buf;

    try expectEqual(s, strcpy(s, ""));
    try expectEqual('\x00', s[0]);
    try expectEqual('x', s[1]);
    try expectEqual(s, strcpy(s, abcde));
    try expectEqual('a', s[0]);
    try expectEqual('e', s[4]);
    try expectEqual('\x00', s[5]);
}

export fn strspn(dest: [*:0]const u8, src: [*:0]const u8) usize {
    const dest_span = mem.span(dest);

    for (dest_span) |c, i| {
        if (strchr(src, c) == null) {
            return i;
        }
    }

    return dest_span.len;
}

test "strspn" {
    const abcde = "abcde";
    try expectEqual(3, strspn(abcde, "abc"));
    try expectEqual(0, strspn(abcde, "b"));
    try expectEqual(5, strspn(abcde, abcde));

    const test_string = "abcde312$#@";
    const low_alpha = "qwertyuiopasdfghjklzxcvbnm";
    try expectEqual(5, strspn(test_string, low_alpha));
}

export fn strcoll(lhs: [*:0]const u8, rhs: [*:0]const u8) c_int {
    return strcmp(lhs, rhs);
}
