const std = @import("std");
const Allocator = std.mem.Allocator;

const riscv = @import("target/arch/riscv.zig");

const Lua = @import("lua.zig").Lua;
const clua = @import("lua.zig").clua;

pub fn kmain(heap_allocator: Allocator) noreturn {
    std.log.info("Welcome to Luxos!", .{});

    // TODO: Install machine mode trap handler to catch whatever is happening in
    // the allocator when using thread safe allocator.

    var lua = Lua.init(heap_allocator) catch {
        std.log.err("Lua state creation failed", .{});
        @panic("Lua init failed");
    };

    std.log.info("Lua state created", .{});

    _ = lua;
    _ = riscv.mcsr.mstatus.read();

    while (true) {}
}
