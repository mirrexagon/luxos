# Luxos
A toy RISC-V RV64GC operating system written in Zig and Lua, that runs Lua scripts as userspace programs.

Luxos is licensed under the 0BSD (BSD 0-clause) license, see `LICENSE`.

The files in `deps` and `inspiration` are under their own licenses - see those directories for more information.

## Name
"Luxos" is just a mutation of "LuaOS".

## Design
- Each process is a separate Lua state, and they communicate via an external IPC mechanism, probably message passing. Check out effil for an example implementation of message passing.
- All scripts run in kernel mode. Permissions are done by denying scripts access to functions/modules.

### Ideas
Have the concept of resources that can be exclusively acquired, eg. Whole Uart, I2C bus, single I2C device - some controller process could acquire a peripheral and be a driver for it, other processes communicate with it via IPC

Processes can create and expose resources for other processes to take, eg. I2C driver acquires I2C bus resource and in turn exposes the ability to create and acquire a resource for a specific device on the bus - request would probably be done via channels/messages.

Resources keep track of provider (eg. Kernel provides low level peripherals, processes can provide virtual resources like a single I2C device) and owner (which process has exclusive access to the resource) - eg. Provider ID 0 is the kernel, otherwise is process ID

Scheme and path system like Redox?

## Inspirations
- Khoros: https://outofhanwell.wordpress.com/2008/08/16/khoros-a-lua-operating-system/
