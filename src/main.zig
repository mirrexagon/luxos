const std = @import("std");
const Allocator = std.mem.Allocator;
const heap = std.heap;
const fmt = std.fmt;

const fe310 = @import("target/soc/fe310-g002.zig");
const prci = fe310.prci;
const gpio = fe310.gpio;
const uart = fe310.uart;

const lua = @import("lua.zig");

extern var __heap_start: u8;
extern var __heap_end: u8;

var _main_allocator: heap.LoggingAllocator(.debug, .crit) = undefined;
var main_allocator: *Allocator = undefined;

pub fn kmain() noreturn {
    init_uart();
    init_heap();

    std.log.notice("Welcome to Luxos!", .{});

    _ = lua.new(main_allocator) catch {
        std.log.emerg("Lua state creation failed", .{});
    };

    while (true) {}
}

fn init_uart() void {
    prci.useExternalCrystalOscillator();
    gpio.setupUart0Gpio();
    uart.Uart0.setBaudRate();
    uart.Uart0.enableTx();
}

fn init_heap() void {
    const heap_size = @ptrToInt(&__heap_end) - @ptrToInt(&__heap_start);
    const heap_start_pointer = @ptrCast([*]u8, &__heap_start);
    const heap_slice = heap_start_pointer[0..heap_size];

    var heap_allocator = heap.ThreadSafeFixedBufferAllocator.init(heap_slice);

    _main_allocator = heap.loggingAllocator(&heap_allocator.allocator);
    main_allocator = &_main_allocator.allocator;
}

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    var buffer = [_]u8{} ** 256;

    const level_txt = comptime level.asText();
    const prefix2 = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    const string = fmt.bufPrint(buffer, level_txt ++ prefix2 ++ format ++ "\r\n", args) catch uart.Uart0.writeString("Log line did not fit in buffer!\r\n");
    defer main_allocator.free(string);

    uart.Uart0.writeString(string);
}
