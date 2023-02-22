const std = @import("std");

export const HUGE_VAL = std.math.floatMax(f64);

export fn pow(base: f64, exponent: f64) f64 {
    return std.math.pow(f64, base, exponent);
}

export fn frexp(arg: f64, exp: *c_int) f64 {
    const result = std.math.frexp(arg);
    exp.* = result.exponent;
    return result.significand;
}

export fn ldexp(arg: f64, exp: c_int) f64 {
    return std.math.ldexp(arg, exp);
}

export fn _fabs(arg: f64) f64 {
    return std.math.fabs(arg);
}
