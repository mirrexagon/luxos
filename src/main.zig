const std = @import("std");
const Allocator = std.mem.Allocator;

const lua = @import("lua.zig");

pub fn kmain(heap_allocator: *Allocator) noreturn {
    std.log.notice("Welcome to Luxos!", .{});

    var L = lua.new(heap_allocator) catch {
        std.log.emerg("Lua state creation failed", .{});
        std.debug.panic("Lua init failed");
    };

    std.log.info("Lua state created", .{});

    while (true) {}
}
