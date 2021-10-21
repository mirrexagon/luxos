const std = @import("std");
const testing = std.testing;

// https://github.com/ziglang/zig/issues/4437#issuecomment-683309291
pub fn expectEqual(expected: anytype, actual: anytype) !void {
    try testing.expectEqual(@as(@TypeOf(actual), expected), actual);
}

test "expectEqual correctly coerces types that std.testing.expectEqual does not" {
    const int_value: u8 = 2;
    try expectEqual(2, int_value);

    const optional_value: ?u8 = null;
    try expectEqual(null, optional_value);

    const Enum = enum { One, Two };
    const enum_value = Enum.One;
    try expectEqual(.One, enum_value);
}
