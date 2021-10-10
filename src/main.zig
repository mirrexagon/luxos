var i: isize = 0;

export fn _start() align(4) linksection(".text.start") callconv(.Naked) noreturn {
    while (i < 1000) {
        i += 1;
    }

    while (true) {}
}
