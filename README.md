# Luxos
A toy RISC-V operating system written in Zig and Lua, that runs Lua scripts as userspace programs.

Luxos is licensed under the 0BSD (BSD 0-clause) license, see `LICENSE`.

The files in `deps` and `inspiration` are under their own licenses - see those directories for more information.

The name "Luxos" is just a mutation of "LuaOS".

## Status
I'm using this project as an excuse to write startup and peripheral code for the FE310-G002 (the SoC on the HiFive1 Rev B) from scratch, as well as the rest of the operating system. Actually using Lua has not happened yet.

The FE310-G002 has only 16 KiB of data RAM which is almost certainly not enough to do much interesting in Lua, so I will probably end up switching to running in QEMU with a RV64GC CPU. Once I get Lua running then we will see how far I can get with it.


## Building and flashing
Currently targets only the HiFive1 Rev B board.

1. Connect board to PC.
1. Start J-Link GDB server with `./start-gdb-server.sh`.
1. `zig build debug` to build kernel, start ugdb, and connect to the GDB server.
1. To flash the kernel to the board, use `load` in GDB. Whenever the kernel is rebuilt, you can run `!reload` to reload the file from disk, then `load` again to flash the updated kernel.


## Inspirations
- Khoros: https://outofhanwell.wordpress.com/2008/08/16/khoros-a-lua-operating-system/
    - Source code is included in `inspiration/`, download linked from http://lua-users.org/lists/lua-l/2011-08/msg01189.html (download link is dead now)
- https://reddit.com/r/rust/comments/8j7y1f/i_am_lachlansneff_creator_of_nebulet_a_rust/dyyzfir/
