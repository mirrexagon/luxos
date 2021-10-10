const assert = @import("std").debug.assert;
const mem = @import("std").mem;

extern var __data_source_start: u8;
extern var __data_source_end: u8;
extern var __data_target_start: u8;
extern var __data_target_end: u8;

extern var __bss_start: u8;
extern var __bss_end: u8;

export fn _start() align(4) linksection(".text.start") callconv(.Naked) noreturn {
    const data_length: usize = @ptrToInt(&__data_source_end) - @ptrToInt(&__data_source_start);
    assert(data_length == (@ptrToInt(&__data_target_end) - @ptrToInt(&__data_target_start)));
    const data_source: []volatile u8 = (&__data_source_start)[0..data_length];
    const data_dest: []volatile u8 = (&__data_source_start)[0..data_length];
    mem.copy(u8, data_dest, data_source);

    while (true) {}
}
