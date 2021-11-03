//! Memory-mapped register abstraction.
//!
//! Adapted from https://scattered-thoughts.net/writing/mmio-in-zig

const assert = @import("std").debug.assert;

pub fn Register(comptime Inner: type, comptime ReadWrite: type) type {
    return AsymmetricRegister(Inner, ReadWrite, ReadWrite);
}

pub fn AsymmetricRegister(comptime Inner: type, comptime Read: type, comptime Write: type) type {
    comptime {
        assert(@bitSizeOf(Read) == @bitSizeOf(Inner));
        assert(@bitSizeOf(Write) == @bitSizeOf(Inner));
    }

    return struct {
        raw_ptr: *volatile Inner,

        const Self = @This();

        pub fn init(address: usize) Self {
            return .{ .raw_ptr = @intToPtr(*volatile Inner, address) };
        }

        pub fn read_raw(self: Self) Inner {
            return self.raw_ptr.*;
        }
        pub fn write_raw(self: Self, value: Inner) void {
            self.raw_ptr.* = value;
        }

        pub fn read(self: Self) Read {
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, value: Write) void {
            self.raw_ptr.* = @bitCast(Inner, value);
        }

        pub fn modify(self: Self, new_value: anytype) void {
            if (Read != Write) {
                @compileError("can't modify because read and write types for this register aren't the same");
            }

            var value = self.read();
            const info = @typeInfo(@TypeOf(new_value));

            // new_value is an anonymous struct type with just the fields specified
            // in it. We try to set fields with the same name in the register
            // struct type to the values in new_value. If the types don't match,
            // or if there are fields in new_value that aren't in the register
            // struct, a compile error naturally occurs.
            inline for (info.Struct.fields) |field| {
                @field(value, field.name) = @field(new_value, field.name);
            }

            self.write(value);
        }
    };
}

test "register" {
    const pin_cnf_val = packed struct {
        dir: enum(u1) {
            input = 0,
            output = 1,
        } = .input,
        input: enum(u1) {
            connect = 0,
            disconnect = 1,
        } = .disconnect,
        pull: enum(u2) {
            disabled = 0,
            pulldown = 1,
            pullup = 3,
        } = .disabled,
        _unused4: u4 = 0,
        drive: enum(u3) {
            s0s1 = 0,
            h0s1 = 1,
            s0h1 = 2,
            h0h1 = 3,
            d0s1 = 4,
            d0h1 = 5,
            s0d1 = 6,
            h0d1 = 7,
        } = .s0s1,
        _unused11: u5 = 0,
        sense: enum(u2) {
            disabled = 0,
            high = 2,
            low = 3,
        } = .disabled,
        _unused18: u14 = 0,
    };

    const reg = Register(u32, pin_cnf_val, pin_cnf_val).new(0x708);

    _ = reg;
}
