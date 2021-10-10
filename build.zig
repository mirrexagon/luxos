const std = @import("std");
const os = std.os;
const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;
const LibExeObjStep = std.build.LibExeObjStep;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    // Main executable.
    const kernel = b.addExecutable("kernel.elf", "src/main.zig");
    kernel.setBuildMode(b.standardReleaseOptions());
    kernel.setTarget(CrossTarget{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.sifive_e31 },
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
    });
    kernel.setLinkerScriptPath("src/hifive1-revb.ld");

    // https://github.com/ziglang/zig/issues/5558
    kernel.code_model = .medium;

    // add_lua(kernel);

    kernel.install();

    // Run in QEMU.
    const run_step = b.step("run", "Run the kernel in QEMU");
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "qemu-system-riscv32",
        "-nographic",
        "-machine",
        "sifive_e,revb=true",

        // -kernel appears to load the binary into data RAM.
        // https://github.com/qemu/qemu/blob/b8fb878aa2485fd41502295f0ff5362a67c8ba68/hw/riscv/sifive_e.c#L110
        //
        // So instead we use the -loader to place the kernel in flash at the location the bootloader jumps to.
        // https://github.com/tock/tock/blob/7fcb3751f02dedc41ca8bbab42819b88cb4bdda8/boards/hifive1/README.md
        // https://qemu.readthedocs.io/en/latest/system/generic-loader.html#loading-files
        "-device",
        "loader,file=zig-out/bin/kernel.elf",
    });
    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);
}

fn add_lua(item: *LibExeObjStep) void {
    const lua_src_dir = "deps/lua-5.4.0/src/";

    const lua_c_files = .{
        "lapi.c",
        "lcode.c",
        "lctype.c",
        "ldebug.c",
        "ldo.c",
        "ldump.c",
        "lfunc.c",
        "lgc.c",
        "llex.c",
        "lmem.c",
        "lobject.c",
        "lopcodes.c",
        "lparser.c",
        "lstate.c",
        "lstring.c",
        "ltable.c",
        "ltm.c",
        "lundump.c",
        "lvm.c",
        "lzio.c",
        "lauxlib.c",
        "lbaselib.c",
        "lcorolib.c",
        "ldblib.c",
        "liolib.c",
        "lmathlib.c",
        "loadlib.c",
        "loslib.c",
        "lstrlib.c",
        "ltablib.c",
        "lutf8lib.c",
        "linit.c",
    };

    const lua_cflags = .{ "-std=c11", "-pedantic", "-Wall", "-Wextra" };

    inline for (lua_c_files) |c_file| {
        item.addCSourceFile(lua_src_dir ++ c_file, &lua_cflags);
    }

    item.addIncludeDir(lua_src_dir);
}
