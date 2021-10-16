const mem = @import("std").mem;

const kmain = @import("main.zig").kmain;

extern var __data_source_start: u8;
extern var __data_source_end: u8;
extern var __data_dest_start: u8;
extern var __data_dest_end: u8;

extern var __bss_start: u8;
extern var __bss_end: u8;

extern var __initial_stack_pointer: u8;

export fn _start() align(4) linksection(".text.start") callconv(.Naked) noreturn {
    // Set up stack pointer.
    const initial_stack_pointer_address = @ptrToInt(&__initial_stack_pointer);
    _ = asm volatile ("mv sp, a0"
        :
        : [initial_stack_pointer_address] "{a0}" (initial_stack_pointer_address)
    );

    // Initialise data and BSS.
    const data_length = @ptrToInt(&__data_source_end) - @ptrToInt(&__data_source_start);
    const data_source = @ptrCast([*]volatile u8, &__data_source_start);
    const data_dest = @ptrCast([*]volatile u8, &__data_dest_start);
    for (data_source[0..data_length]) |b, i| data_dest[i] = b;

    const bss_length = @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start);
    const bss_dest = @ptrCast([*]volatile u8, &__bss_start);
    for (bss_dest[0..bss_length]) |*b| b.* = 0;

    kmain();
}
