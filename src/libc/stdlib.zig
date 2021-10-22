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

export fn strtod(str: [*:0]const u8, str_end: **const u8) f64 {
    var int_part: f64 = 0.0;
    var frac_part: f64 = 0.0;
    var base10exp: f64 = 0.0;
    var sign: f64 = 1.0;

    var i: usize = 0;

    // Skip whitespace.
    while (isWhitespace(str[i])) : (i += 1) {}

    // Determine sign.
    if (str[i] == '-') {
        i += 1;
        sign = -1;
    } else if (str[i] == '+') {
        i += 1;
    }

    while (str[i] != 0 and isDigit(str[i])) : (i += 1) {
        int_part *= 10;
        int_part += @intToFloat(f64, str[i] - '0');
    }

    if (str[i] == '.') {
        i += 1;

        while (str[i] != 0 and isDigit(str[i])) : (i += 1) {
            frac_part += @intToFloat(f64, str[i] - '0');
            frac_part *= 0.1;
        }
    }

    if (str[i] == 'e' or str[i] == 'E') {
        i += 1;

        while (str[i] != 0 and isDigit(str[i])) : (i += 1) {
            base10exp *= 10;
            base10exp += @intToFloat(f64, str[i] - '0');
        }
    }

    str_end.* = &str[i];

    return sign * int_part + frac_part;
}

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\x0c' or c == '\n' or c == '\r' or c == '\x09' or c == '\x0b';
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
