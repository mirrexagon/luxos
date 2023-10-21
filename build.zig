const std = @import("std");
const os = std.os;
const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;
const LibExeObjStep = std.build.LibExeObjStep;
const FileSource = std.build.FileSource;
const builtin = @import("builtin");

const cflags = .{
    "-std=c11",
    //"-pedantic", "-Wall", "-Wextra"

    // Lua fails some undefined behaviour checks, so in the interests of not
    // having to modify Lua, we turn off the checks.
    "-fno-sanitize=undefined",
};

pub fn build(b: *Builder) void {
    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .cpu_model = .{ .explicit = &Target.riscv.cpu.sifive_e31 },
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
    };

    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = .{ .path = "src/start.zig" },
        .target = target,
        .optimize = optimize,
    });

    {
        kernel.setLinkerScriptPath(FileSource.relative("src/target/board/hifive1-revb/linker.ld"));

        // https://github.com/ziglang/zig/issues/5558
        kernel.code_model = .medium;

        add_lua(kernel);
        add_libc(b, target, optimize, kernel);

        b.installArtifact(kernel);
    }

    b.default_step.dependOn(&kernel.step);

    const debug_step = b.step("debug", "Debug connected HiFive1 Rev B board");
    const debug_cmd = b.addSystemCommand(&[_][]const u8{
        "ugdb",
        "--command",
        "src/target/board/hifive1-revb/gdbcommands",
        "--layout",
        "s-c", // Don't add expressions table and terminal panels.
        "zig-out/bin/kernel.elf",
    });
    debug_cmd.step.dependOn(b.getInstallStep());
    debug_step.dependOn(&debug_cmd.step);
}

fn add_lua(item: *LibExeObjStep) void {
    const lua_src_dir = "deps/lua-5.4.4/src/";

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

        // "lauxlib.c",
        // "lbaselib.c",
        // "lcorolib.c",
        // "ldblib.c",
        // "liolib.c",
        // "lmathlib.c",
        // "loadlib.c",
        // "loslib.c",
        // "lstrlib.c",
        // "ltablib.c",
        // "lutf8lib.c",
        // "linit.c",
    };

    inline for (lua_c_files) |c_file| {
        item.addCSourceFile(.{
            .file = .{ .path = lua_src_dir ++ c_file },
            .flags = &cflags,
        });
    }

    item.addIncludePath(.{ .path = lua_src_dir });
    item.addIncludePath(.{ .path = "src/libc/include" });

    item.defineCMacro("lua_getlocaledecpoint()", "('.')");
    item.defineCMacro("LUA_USE_APICHECK", "1");
    item.defineCMacro("LUAI_ASSERT", "1");
}

fn add_libc(b: *Builder, target: CrossTarget, optimize: std.builtin.Mode, item: *LibExeObjStep) void {
    const libc_src_dir = "src/libc/";

    const libc_files = .{
        .{ "string", "string.zig" },
        .{ "stdlib", "stdlib.zig" },
        .{ "time", "time.zig" },
        .{ "math", "math.zig" },
        .{ "setjmp", "setjmp.zig" },
        .{ "ctype", "ctype.zig" },
        .{ "assert", "assert.zig" },
    };

    inline for (libc_files) |file| {
        const obj = b.addObject(.{
            .name = file.@"0",
            .root_source_file = .{ .path = libc_src_dir ++ file.@"1" },
            .target = target,
            .optimize = optimize,
        });
        obj.addIncludePath(.{ .path = "src/libc/include" });
        item.addObject(obj);
    }

    item.addCSourceFile(.{ .file = .{ .path = libc_src_dir ++ "snprintf.c" }, .flags = &cflags });
}
