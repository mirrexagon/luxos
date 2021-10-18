const std = @import("std");

pub const lua = @cImport({
    @cInclude("lua.h");
    // @cInclude("lauxlib.h");
    // @cInclude("lualib.h");
});

pub fn new(allocator: *std.mem.Allocator) !*lua.lua_State {
    return lua.lua_newstate(luaAlloc, allocator) orelse return error.OutOfMemory;
}

/// Function used as the Lua state allocator function, bridging between the Lua
/// allocator function contract and Zig allocators.
fn luaAlloc(ud: ?*c_void, ptr: ?*c_void, osize: usize, nsize: usize) callconv(.C) ?*c_void {
    // ?*c_void has an alignment of 1, but the Allocator struct has a larger
    // alignment. We know that ud is a pointer to an Allocator (as passed in
    // new()) and so this is okay.
    const allocator_aligned = @alignCast(@alignOf(std.mem.Allocator), ud);
    const allocator = @ptrCast(*std.mem.Allocator, allocator_aligned);

    // malloc() in C guarantees valid alignment for any type, so we must match
    // that guarantee.
    //
    // This method of determining the required alignment is from here:
    // https://github.com/ziglang/zig/blob/2117fbdae35dddf368c4ce5bb39cc73fa0f78d4c/lib/include/__stddef_max_align_t.h
    const alignment = @alignOf(extern struct {
        one: c_longlong align(@alignOf(c_longlong)),
        two: c_longdouble align(@alignOf(c_longdouble)),
    });

    // The memory pointed to by ptr was allocated by this function and so has
    // the alignment we are using.
    const ptr_aligned = @alignCast(alignment, ptr);

    // We cast the pointer to a multiple-item pointer so that it can be sliced
    // to be passed to the allocator, since we are allocating slices of u8 in
    // the first place.
    const ptr_multi = @ptrCast(?[*]align(alignment) u8, ptr_aligned);

    if (ptr_multi) |previous_ptr| {
        const previous_block = previous_ptr[0..osize];

        if (nsize <= osize) {
            // Shrinking or freeing (if nsize == 0) a block.
            // shrink() is used instead of realloc() because Lua assumes that
            // shrinking never fails.
            const new_block = allocator.shrink(previous_block, nsize);
            return new_block.ptr;
        } else {
            // Expanding a block.
            const new_block = allocator.realloc(previous_block, nsize) catch return null;
            return new_block.ptr;
        }
    } else {
        // Allocating a new block.
        const allocated_block = allocator.allocAdvanced(u8, alignment, nsize, .exact) catch return null;
        return allocated_block.ptr;
    }
}
