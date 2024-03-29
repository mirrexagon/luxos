const std = @import("std");

pub const clua = @cImport({
    @cInclude("lua.h");
    // @cInclude("lauxlib.h");
    // @cInclude("lualib.h");
});

pub const Lua = struct {
    L: *clua.lua_State,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Lua {
        // Even if the Lua struct is moved around, we want the allocator to be
        // in the same place. So we allocate memory for it!
        var staticAllocator = try allocator.create(std.mem.Allocator);
        staticAllocator.* = allocator;
        errdefer allocator.destroy(staticAllocator);

        var L = clua.lua_newstate(luaAlloc, staticAllocator) orelse return error.OutOfMemory;

        return Lua{
            .L = L,
            .allocator = staticAllocator,
        };
    }

    /// Function used as the Lua state allocator function, bridging between the Lua
    /// allocator function contract and Zig allocators.
    fn luaAlloc(ud: ?*anyopaque, ptr: ?*anyopaque, osize: usize, nsize: usize) callconv(.C) ?*anyopaque {
        // ?*anyopaque has an alignment of 1, but the Allocator struct has a larger
        // alignment. We know that ud is a pointer to an Allocator (as passed in
        // new()) and so this is okay.
        const allocator: *std.mem.Allocator = @ptrCast(@alignCast(ud));

        // malloc() in C guarantees valid alignment for any type, so we must match
        // that guarantee.
        //
        // This method of determining the required alignment is from here:
        // https://github.com/ziglang/zig/blob/2117fbdae35dddf368c4ce5bb39cc73fa0f78d4c/lib/include/__stddef_max_align_t.h
        const alignment = @alignOf(extern struct {
            one: c_longlong,
            two: c_longdouble,
        });

        // The memory pointed to by ptr was allocated by this function and so has
        // the alignment we are using.
        const ptr_aligned: *align(alignment) u8 = @ptrCast(@alignCast(ptr));

        // We cast the pointer to a multiple-item pointer so that it can be sliced
        // to be passed to the allocator, since we are allocating slices of u8 in
        // the first place.
        const ptr_multi = @as(?[*]align(alignment) u8, @ptrCast(ptr_aligned));

        if (ptr_multi) |previous_ptr| {
            // Resizing/allocating or freeing a block.
            const previous_block = previous_ptr[0..osize];
            const new_block = allocator.realloc(previous_block, nsize) catch return null;
            return new_block.ptr;
        } else {
            // Allocating a new block.
            const allocated_block = allocator.allocWithOptions(u8, nsize, alignment, null) catch return null;
            return allocated_block.ptr;
        }
    }
};
