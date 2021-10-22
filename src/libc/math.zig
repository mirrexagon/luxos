const std = @import("std");

export fn pow(base: f64, exponent: f64) f64 {
    return std.math.pow(f64, base, exponent);
}

export fn frexp(arg: f64, exp: *c_int) f64 {
    if (arg == 0.0) {
        exp.* = 0;
        return 0.0;
    }
}
