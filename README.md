# Luxos
A toy RISC-V operating system written in Zig and Lua, that runs Lua scripts as userspace programs.

Luxos is licensed under the 0BSD (BSD 0-clause) license, see `LICENSE`.

The files in `deps` and `inspiration` are under their own licenses - see those directories for more information.

The name "Luxos" is just a mutation of "LuaOS".


## Building and flashing
Currently targets the HiFive1 Rev B board.

1. Connect board to PC.
1. Start J-Link GDB server with `./start-gdb-server.sh`.
1. `zig build debug` to build kernel, start ugdb, and connect to the GDB server.
1. To flash the kernel to the board, use `load` in GDB. Whenever the kernel is rebuilt, you can run `!reload` to reload the file from disk, then `load` again to flash the updated kernel.


## Inspirations
- Khoros: https://outofhanwell.wordpress.com/2008/08/16/khoros-a-lua-operating-system/
