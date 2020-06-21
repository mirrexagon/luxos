const uefi = @import("std").os.uefi;
const InputKey = uefi.protocols.InputKey;

const fmt = @import("std").fmt;

var con_out: *uefi.protocols.SimpleTextOutputProtocol = undefined;

fn puts(msg: []const u8) void {
    for (msg) |c| {
        const c_ = [2]u16{ c, 0 }; // work around https://github.com/ziglang/zig/issues/4372
        _ = con_out.outputString(@ptrCast(*const [1:0]u16, &c_));
    }
}

fn printf(buf: []u8, comptime format: []const u8, args: var) void {
    puts(fmt.bufPrint(buf, format, args) catch unreachable);
}

pub fn main() void {
    con_out = uefi.system_table.con_out.?;
    var key: uefi.protocols.InputKey = undefined;
    var con_in = uefi.system_table.con_in.?;
    const boot_services = uefi.system_table.boot_services.?;
    var buf: [256]u8 = undefined;

    var memory_map: [*]uefi.tables.MemoryDescriptor = undefined;
    var memory_map_size: usize = 0;
    var memory_map_key: usize = undefined;
    var descriptor_size: usize = undefined;
    var descriptor_version: u32 = undefined;
    // Fetch the memory map.
    // Careful! Every call to boot services can alter the memory map.
    while (uefi.Status.BufferTooSmall == boot_services.getMemoryMap(&memory_map_size, memory_map, &memory_map_key, &descriptor_size, &descriptor_version)) {
        // allocatePool is the UEFI equivalent of malloc. allocatePool may
        // alter the size of the memory map, so we must check the return
        // value of getMemoryMap every time.
        if (uefi.Status.Success != boot_services.allocatePool(uefi.tables.MemoryType.BootServicesData, memory_map_size, @ptrCast(*[*] align(8) u8, &memory_map))) {
            return;
        }
    }

    // Reset the input device so it gets flushed?
    _ = con_in.reset(false);

    // You'll need memory_map_key to call exitBootServices().

    var i: usize = 0;
    while (i < memory_map_size / descriptor_size) : (i += 1) {
        // See the UEFI specification for more information on the attributes.
        printf(buf[0..], "*** {:3} type={s:23} physical=0x{x:0>16} virtual=0x{x:0>16} pages={:16} uc={} wc={} wt={} wb={} uce={} wp={} rp={} xp={} nv={} more_reliable={} ro={} sp={} cpu_crypto={} memory_runtime={}\r\n", .{ i, @tagName(memory_map[i].type), memory_map[i].physical_start, memory_map[i].virtual_start, memory_map[i].number_of_pages, @boolToInt(memory_map[i].attribute.uc), @boolToInt(memory_map[i].attribute.wc), @boolToInt(memory_map[i].attribute.wt), @boolToInt(memory_map[i].attribute.wb), @boolToInt(memory_map[i].attribute.uce), @boolToInt(memory_map[i].attribute.wp), @boolToInt(memory_map[i].attribute.rp), @boolToInt(memory_map[i].attribute.xp), @boolToInt(memory_map[i].attribute.nv), @boolToInt(memory_map[i].attribute.more_reliable), @boolToInt(memory_map[i].attribute.ro), @boolToInt(memory_map[i].attribute.sp), @boolToInt(memory_map[i].attribute.cpu_crypto), @boolToInt(memory_map[i].attribute.memory_runtime) });

        // Wait for a keypress.
        while (con_in.readKeyStroke(&key) == uefi.Status.NotReady) {}
    }

    printf(buf[0..], "le finished\r\n", .{});

    _ = boot_services.stall(10 * 1000 * 1000);

    // Wait for a keypress.
    while (con_in.readKeyStroke(&key) == uefi.Status.NotReady) {}
}
