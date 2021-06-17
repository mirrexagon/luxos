export fn _start() callconv(.Naked) noreturn {
    var i: i32 = 0;

    while (i < 1000) {
        i += 1;
    }

    while (true) {}
}
