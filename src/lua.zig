const std = @import("std");

pub const lua = @cImport({
    @cInclude("lua.h");
    @cInclude("lauxlib.h");
    @cInclude("lualib.h");
});

pub fn new(allocator: *std.mem.Allocator) *lua.lua_State {
    return lua.lua_newstate(luaAlloc, allocator);
}

fn luaAlloc(ud: ?*c_void, ptr: ?*c_void, osize: usize, nsize: usize) callconv(.C) ?*c_void {
    const allocator = @ptrCast(*std.mem.Allocator, ud);

    return null;
}
