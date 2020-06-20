const Builder = @import("std").build.Builder;

const lua_src_dir = "deps/lua-5.3.5/src/";

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("luxos", "src/main.zig");
    exe.setBuildMode(mode);

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

    exe.linkSystemLibrary("c");
    exe.addIncludeDir(lua_src_dir);
    exe.install();

    const run_step_top_level = b.step("run", "Run");
    const run_step = exe.run();
    run_step.step.dependOn(b.getInstallStep());
    run_step_top_level.dependOn(&run_step.step);
}

