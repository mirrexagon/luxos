const std = @import("std");
const Allocator = std.mem.Allocator;

const riscv = @import("target/arch/riscv.zig");

const Lua = @import("lua.zig").Lua;
const clua = @import("lua.zig").clua;

pub fn kmain(heap_allocator: Allocator) noreturn {
    std.log.info("Welcome to Luxos!", .{});

    const trap_handler_ptr: *const fn () align(4) callconv(.Naked) void = trapHandler;
    riscv.mcsr.mtvec.write(.{ .mode = .direct, .base = @as(u30, @truncate(@intFromPtr(trap_handler_ptr) >> 2)) });

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

// TODO: Proper register preservation, stack switching, etc.
// https://osblog.stephenmarz.com/ch4.html
fn trapHandler() align(4) callconv(.Naked) void {
    _ = asm volatile (
        \\jal x0, logTrap
        :
        : [logTrap] "X" (&logTrap),
    );
}

export fn logTrap() void {
    var mcause = riscv.mcsr.mcause.read();
    var mtval = riscv.mcsr.mtval.read();
    var mepc = riscv.mcsr.mepc.read();

    std.log.info("Trap: mcause {}, mtval 0x{x}, mepc 0x{x}", .{ mcause.code, mtval, mepc });

    @panic("Trapped");
}
