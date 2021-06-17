# Luxos
A toy RISC-V RV64GC operating system written in Zig and Lua, that runs Lua scripts as userspace programs.

Luxos is licensed under the 0BSD (BSD 0-clause) license, see `LICENSE`.

The files in `deps` and `inspiration` are under their own licenses - see those directories for more information.

## Name
"Luxos" is just a mutation of "LuaOS".

## Design
- Each process is a separate Lua state, and they communicate via an external IPC mechanism, probably message passing. Check out effil for an example implementation of message passing.
- All scripts run in kernel mode. Permissions are done by denying scripts access to functions/modules.

## Inspirations
- Khoros: https://outofhanwell.wordpress.com/2008/08/16/khoros-a-lua-operating-system/
