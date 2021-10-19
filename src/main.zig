const std = @import("std");
const Allocator = std.mem.Allocator;
const ThreadSafeFixedBufferAllocator = std.heap.ThreadSafeFixedBufferAllocator;

const fe310 = @import("target/soc/fe310-g002.zig");
const prci = fe310.prci;
const gpio = fe310.gpio;
const uart = fe310.uart;

const libc = @import("libc.zig");
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
    const heap = heap_start_pointer[0..heap_size];

    var heap_allocator = ThreadSafeFixedBufferAllocator.init(heap);

    _ = lua.new(&heap_allocator.allocator) catch {
        for ("Creating Lua state failed\r\n") |c| {
            uart.Uart0.writeByte(c);
        }
    };

    while (true) {}
}
