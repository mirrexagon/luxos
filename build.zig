const std = @import("std");
const os = std.os;
const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;
const LibExeObjStep = std.build.LibExeObjStep;
const builtin = @import("builtin");


pub fn build(b: *Builder) void {
    // Main executable.
    const kernel = b.addExecutable("bootx64", "src/main.zig");
    kernel.setBuildMode(b.standardReleaseOptions());
    kernel.setTarget(CrossTarget{
        .cpu_arch = Target.Cpu.Arch.x86_64,
        .os_tag = Target.Os.Tag.uefi,
        .abi = Target.Abi.msvc,
    });
    kernel.setOutputDir("efi/boot");
    kernel.install();

    // add_lua(kernel);

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

fn add_lua(item: *LibExeObjStep) void {
    const lua_src_dir = "deps/lua-5.3.5/src/";

    const lua_c_files = .{
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

    const lua_cflags = .{
        "-std=c11",
        "-pedantic",
        "-Wall",
        "-Wextra"
    };

    inline for (lua_c_files) |c_file| {
        item.addCSourceFile(lua_src_dir ++ c_file, &lua_cflags);
    }

    item.addIncludeDir(lua_src_dir);
}
