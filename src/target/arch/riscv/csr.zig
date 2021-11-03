const std = @import("std");
const assert = std.debug.assert;

pub fn Csr(comptime csr: u12, comptime Inner: type) type {
    assert(@bitSizeOf(Inner) == @bitSizeOf(usize));

    return struct {
        const Self = @This();

        pub fn read() Inner {
            return @bitCast(Inner, Self.readRaw());
        }

        pub fn write(value: Inner) void {
            Self.writeRaw(@bitCast(usize, value));
        }

        pub fn modify(new_value: anytype) void {
            var value = Self.read();
            const info = @typeInfo(@TypeOf(new_value));

            // new_value is an anonymous struct type with just the fields specified
            // in it. We try to set fields with the same name in the register
            // struct type to the values in new_value. If the types don't match,
            // or if there are fields in new_value that aren't in the register
            // struct, a compile error naturally occurs.
            inline for (info.Struct.fields) |field| {
                @field(value, field.name) = @field(new_value, field.name);
            }

            Self.write(value);
        }

        pub fn readRaw() usize {
            return asm volatile ("csrr %[ret], %[csr]"
                : [ret] "=r" (-> usize),
                : [csr] "i" (csr),
            );
        }

        pub fn writeRaw(value: usize) void {
            asm volatile ("csrw %[csr], %[value]"
                :
                : [csr] "i" (csr),
                  [value] "r" (value),
            );
        }
    };
}
