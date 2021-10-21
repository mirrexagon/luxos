const std = @import("std");

export fn time(arg: ?*c_ulonglong) c_ulonglong {
    // TODO: Used by Lua core for randomization, maybe make this random.
    // Not planning to use the os library as-is so this shouldn't affect it.
    const current_time = 0;

    if (arg) |non_null| {
        non_null.* = current_time;
    }

    return current_time;
}
