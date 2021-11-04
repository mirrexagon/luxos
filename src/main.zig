const std = @import("std");
const Allocator = std.mem.Allocator;

const riscv = @import("target/arch/riscv.zig");

const lua = @import("lua.zig");

pub fn kmain(heap_allocator: *Allocator) noreturn {
    std.log.notice("Welcome to Luxos!", .{});

    // TODO: Install machine mode trap handler to catch whatever is happening in the allocator when initialising Lua.

    // _ = lua.new(heap_allocator) catch {
    //     std.log.emerg("Lua state creation failed", .{});
    //     @panic("Lua init failed");
    // };
    // std.log.info("Lua state created", .{});
    _ = heap_allocator;

    _ = riscv.mcsr.mstatus.read();

    while (true) {}
}
