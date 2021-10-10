extern var __data_source_start: u8;
extern var __data_source_end: u8;
extern var __data_target_start: u8;
extern var __data_target_end: u8;

extern var __bss_source_start: u8;
extern var __bss_source_end: u8;
extern var __bss_target_start: u8;
extern var __bss_target_end: u8;

const limit: usize = 1000;
var i: usize = 6;

export fn _start() align(4) linksection(".text.start") callconv(.Naked) noreturn {
    while (i < limit) {
        i += 1;
    }

    while (true) {}
}
