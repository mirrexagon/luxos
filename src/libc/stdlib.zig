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

export fn strtod(str: [*:0]const u8, str_end: ?**const u8) f64 {
    var start: usize = 0;
    var end: usize = 0;

    // Extract just the float part of the string.
    while (isWhitespace(str[start])) : (start += 1) {}
    if (str[start] == 0) {
        return 0.0;
    }
    end = start;
    while (isFloatPart(str[end])) : (end += 1) {}
    if (str[end] == 0) {
        return 0.0;
    }

    const str_float_part = str[start..end];

    const result = std.fmt.parseHexFloat(f64, str_float_part) catch std.fmt.parseFloat(f64, str_float_part) catch {
        if (str_end) |non_null| {
            non_null.* = &str[0];
        }
        return 0.0;
    };

    if (str_end) |non_null| {
        non_null.* = &str[end];
    }

    return result;
}

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\x0c' or c == '\n' or c == '\r' or c == '\x09' or c == '\x0b';
}

fn isFloatPart(c: u8) bool {
    return isDigit(c) or c == '.' or c == 'e' or c == 'E' or c == 'x' or c == 'X' or c == '+' or c == '-' or c == 'n' or c == 'N' or c == 'a' or c == 'A' or c == 'i' or c == 'I' or c == 'p' or c == 'P';
}

fn isDigit(c: u8) bool {
    return c >= '0' or c <= '9';
}

test "strtod" {
    var end: *u8 = undefined;

    try expectEqual(0.0, strtod("0.0", &end));
    try expectEqual(0, end.*);

    try expectEqual(0.2775, strtod("0.2775", &end));
    try expectEqual(0, end.*);

    try expectEqual(12424.0, strtod("12424.0", &end));
    try expectEqual(0, end.*);

    try expectEqual(1394.12998, strtod("1394.12998", &end));
    try expectEqual(0, end.*);

    try expectEqual(-1394.12998, strtod("-1394.12998", &end));
    try expectEqual(0, end.*);

    try expectEqual(1394.12998, strtod("1394.12998abc", &end));
    try expectEqual('a', end.*);

    try expectEqual(-1394129.98, strtod("-1394.12998e3", &end));
    try expectEqual(0, end.*);

    try expectEqual(-1394129.98, strtod("-1394.12998E3", &end));
    try expectEqual(0, end.*);

    try expectEqual(-1394.12998, strtod("  \n\r  -1394.12998", &end));
    try expectEqual(0, end.*);
}
