const std = @import("std");
const os = std.os;
const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;
const LibExeObjStep = std.build.LibExeObjStep;
const builtin = @import("builtin");


pub fn build(b: *Builder) void {
    // Main executable.
    const exe = b.addExecutable("bootx64", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setTarget(CrossTarget{
        .cpu_arch = Target.Cpu.Arch.x86_64,
        .os_tag = Target.Os.Tag.uefi,
        .abi = Target.Abi.msvc,
    });
    exe.setOutputDir("efi/boot");
    exe.install();

    // add_lua(exe);

    // Run in QEMU.
    // qemu-system-x86_64 -bios path/to/OVMF.fd -hdd fat:rw:. -serial stdio
    const run_step = b.step("run", "Run the kernel in QEMU");
    const run_cmd = b.addSystemCommand(&[_][]const u8 {
        "qemu-system-x86_64",
        "-bios", os.getenv("OVMF_PATH").?, // Set by `shell.nix`.
        "-drive", "format=raw,file=fat:rw:.",
        "-serial", "stdio",
        "-net", "none"
    });
    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);
}

fn add_lua(exe: *LibExeObjStep) void {
    const lua_src_dir = "deps/lua-5.3.5/src/";

    const lua_c_files = [_][]const u8 {
        "lapi.c",
        "lauxlib.c",
        "lbaselib.c",
        "lbitlib.c",
        "lcode.c",
        "lcorolib.c",
        "lctype.c",
        "ldblib.c",
        "ldebug.c",
        "ldo.c",
        "ldump.c",
        "lfunc.c",
        "lgc.c",
        "linit.c",
        "liolib.c",
        "llex.c",
        "lmathlib.c",
        "lmem.c",
        "loadlib.c",
        "lobject.c",
        "lopcodes.c",
        "loslib.c",
        "lparser.c",
        "lstate.c",
        "lstring.c",
        "lstrlib.c",
        "ltable.c",
        "ltablib.c",
        "ltm.c",
        "lundump.c",
        "lutf8lib.c",
        "lvm.c",
        "lzio.c",
    };

    const lua_cflags = [_][]const u8 {
        "-std=c11",
        "-pedantic",
        "-Wall",
        "-Wextra"
    };

    inline for (lua_c_files) |c_file| {
        exe.addCSourceFile(lua_src_dir ++ c_file, &lua_cflags);
    }

    exe.addIncludeDir(lua_src_dir);
}
