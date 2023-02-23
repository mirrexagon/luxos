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

    clua.lua_pushinteger(lua.L, 1);
    clua.lua_pushinteger(lua.L, 1);
    clua.lua_arith(lua.L, clua.LUA_OPADD);
    var result = clua.lua_tointeger(lua.L, -1);

    std.log.info("Lua calculated: 1 + 1 = {}", .{result});

    while (true) {}
}

fn trapHandler() align(4) callconv(.Naked) void {
    var mcause = riscv.mcsr.mcause.read();
    var mtval = riscv.mcsr.mtval.read();
    var mepc = riscv.mcsr.mepc.read();

    std.log.info("Trap: mcause {}, mtval 0x{x}, mepc 0x{x}", .{ mcause.code, mtval, mepc });

    @panic("Trapped");
}
