const std = @import("std");

export fn pow(base: f64, exponent: f64) f64 {
    return std.math.pow(f64, base, exponent);
}

export fn frexp(arg: f64, exp: *c_int) f64 {
    const result = std.math.frexp(arg);
    exp.* = result.exponent;
    return result.significand;
}
