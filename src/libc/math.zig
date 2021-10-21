const std = @import("std");

export fn pow(base: f64, exponent: f64) f64 {
    return std.math.pow(f64, base, exponent);
}
