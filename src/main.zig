const std = @import("std");
const Allocator = std.mem.Allocator;

const riscv = @import("target/arch/riscv.zig");

const Lua = @import("lua.zig").Lua;
const clua = @import("lua.zig").clua;

pub fn kmain(heap_allocator: Allocator) noreturn {
    std.log.info("Welcome to Luxos!", .{});

    std.log.debug("mstatus: {}", .{riscv.mcsr.mstatus.read()});

    const trap_handler_ptr: *const fn () align(4) callconv(.Naked) void = trapHandler;
    riscv.mcsr.mtvec.write(.{ .mode = .direct, .base = @truncate(u30, @ptrToInt(trap_handler_ptr) >> 2) });
    std.log.debug("mtvec: {}", .{riscv.mcsr.mtvec.read()});

    // TODO: Install machine mode trap handler to catch whatever is happening in
    // the allocator when using thread safe allocator.

    var lua = Lua.init(heap_allocator) catch {
        std.log.err("Lua state creation failed", .{});
        @panic("Lua init failed");
    };

    std.log.info("Lua state created", .{});

    _ = lua;

    while (true) {}
}

fn trapHandler() align(4) callconv(.Naked) void {
    var mcause = riscv.mcsr.mcause.read();

    std.log.info("Trap: mcause {}", .{mcause.code});

    @panic("Trapped");
}
