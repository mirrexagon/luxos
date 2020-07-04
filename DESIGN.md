## Overview
A toy operating system written in C and Lua, that runs Lua scripts as programs.

## Ideas

- Each process is a separate Lua state, and they communicate via an external IPC mechanism, probably message passing. Check out effil for an example implementation of message passing.
- All scripts run in kernel mode. Permissions are done by denying scripts access to functions/modules.
- Drivers run as Lua processes.
