const std = @import("std");

const c = @cImport({
    @cInclude("time.h");
});

export fn time(arg: ?*c.time_t) c.time_t {
    // TODO: Used by Lua core for randomization, maybe make this random.
    // Not planning to use the os library as-is so this shouldn't affect it.
    const current_time = 0;

    if (arg) |non_null| {
        non_null.* = current_time;
    }

    return current_time;
}
