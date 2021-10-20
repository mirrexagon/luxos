const std = @import("std");
const Allocator = std.mem.Allocator;
const heap = std.heap;

const fe310 = @import("target/soc/fe310-g002.zig");
const prci = fe310.prci;
const gpio = fe310.gpio;
const uart = fe310.uart;

const lua = @import("lua.zig");

extern var __heap_start: u8;
extern var __heap_end: u8;

pub fn kmain() noreturn {
    prci.useExternalCrystalOscillator();
    gpio.setupUart0Gpio();

    uart.Uart0.setBaudRate();
    uart.Uart0.enableTx();

    for ("Welcome to Luxos!\r\n") |c| {
        uart.Uart0.writeByte(c);
    }

    const heap_size = @ptrToInt(&__heap_end) - @ptrToInt(&__heap_start);
    const heap_start_pointer = @ptrCast([*]u8, &__heap_start);
    const heap_slice = heap_start_pointer[0..heap_size];

    var heap_allocator = heap.ThreadSafeFixedBufferAllocator.init(heap_slice);
    var logging_allocator = heap.loggingAllocator(&heap_allocator.allocator);

    _ = lua.new(&logging_allocator.allocator) catch {
        for ("Creating Lua state failed\r\n") |c| {
            uart.Uart0.writeByte(c);
        }
    };

    while (true) {}
}

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    // TODO
}
