const std = @import("std");

export fn _libc_assert(condition_string: [*:0]const u8, condition: c_int) void {
    if (condition == 0) {
        //std.log.err("Assertion failed: {}", .{condition_string});
        _ = condition_string;
        @panic("assert() from libc was called");
    }
}
