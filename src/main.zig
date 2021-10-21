const std = @import("std");
const Allocator = std.mem.Allocator;

const lua = @import("lua.zig");

pub fn kmain(heap_allocator: *Allocator) noreturn {
    std.log.notice("Welcome to Luxos!", .{});

    _ = heap_allocator;

    // _ = lua.new(heap_allocator) catch {
    //     std.log.emerg("Lua state creation failed", .{});
    // };

    while (true) {}
}
