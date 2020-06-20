const std = @import("std");

const lua = @cImport({
    @cInclude("lua.h");
    @cInclude("lualib.h");
    @cInclude("lauxlib.h");
});

pub fn main() void {
    var L = lua.luaL_newstate();
    defer lua.lua_close(L);

    lua.luaL_openlibs(L);

    _ = lua.luaL_loadstring(L, "print(_VERSION)");
    _ = lua.lua_pcallk(L, 0, lua.LUA_MULTRET, 0, 0, null);
}
