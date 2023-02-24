const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const fmt = std.fmt;
const Allocator = std.mem.Allocator;

const fe310 = @import("target/soc/fe310-g002.zig");
const prci = fe310.prci;
const gpio = fe310.gpio;
const uart = fe310.uart;

const kmain = @import("main.zig").kmain;

extern var __data_source_start: u8;
extern var __data_source_end: u8;
extern var __data_dest_start: u8;
extern var __data_dest_end: u8;

extern var __bss_start: u8;
extern var __bss_end: u8;

extern var __stack_end: u8;

extern var __heap_start: u8;
extern var __heap_end: u8;

var _main_allocator: heap.LoggingAllocator(.debug, .err) = undefined;
var main_allocator: Allocator = undefined;

export fn _start() align(4) linksection(".text.start") callconv(.Naked) noreturn {
    // Set up stack and frame pointers.
    _ = asm volatile (
        \\mv sp, %[initial_stack_pointer_address]
        \\mv fp, sp
        :
        : [initial_stack_pointer_address] "r" (@ptrToInt(&__stack_end)),
        : "sp", "fp"
    );

    // Initialise data and BSS.
    const data_length = @ptrToInt(&__data_source_end) - @ptrToInt(&__data_source_start);
    const data_source = @ptrCast([*]volatile u8, &__data_source_start);
    const data_dest = @ptrCast([*]volatile u8, &__data_dest_start);
    for (data_source[0..data_length]) |b, i| data_dest[i] = b;

    const bss_length = @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start);
    const bss_dest = @ptrCast([*]volatile u8, &__bss_start);
    for (bss_dest[0..bss_length]) |*b| b.* = 0;

    prci.setupHfclk();

    init_uart();
    init_heap();

    std.log.debug("hfclk is {}", .{prci.getHfclkHz()});

    kmain(main_allocator);
}

fn init_uart() void {
    gpio.setupUart0Gpio();
    uart.Uart0.setBaudRate(115200);
    uart.Uart0.enableTx();
    uart.Uart0.writeString("UART0 initialized\r\n");
}

fn init_heap() void {
    const heap_size = @ptrToInt(&__heap_end) - @ptrToInt(&__heap_start);
    const heap_start_pointer = @ptrCast([*]u8, &__heap_start);
    const heap_slice = heap_start_pointer[0..heap_size];

    // TODO: Use thread safe allocator?
    var heap_allocator = heap.FixedBufferAllocator.init(heap_slice);

    _main_allocator = heap.loggingAllocator(heap_allocator.allocator());
    main_allocator = _main_allocator.allocator();

    std.log.debug("Heap initialized", .{});
}

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    var buffer = [_]u8{0} ** 256;

    const level_txt = comptime level.asText();
    const prefix2 = if (scope == .default) " " else "(" ++ @tagName(scope) ++ ") ";

    const string = fmt.bufPrint(&buffer, "[" ++ level_txt ++ "]" ++ prefix2 ++ format ++ "\r\n", args) catch return uart.Uart0.writeString("Log line did not fit in buffer!\r\n");

    uart.Uart0.writeString(string);
}

pub fn panic(message: []const u8, stack_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = stack_trace;
    _ = ret_addr;

    uart.Uart0.writeString("\r\n!!! LUXOS PANIC !!!\r\n");
    uart.Uart0.writeString(message);
    uart.Uart0.writeString("\r\n");

    while (true) {}
}
