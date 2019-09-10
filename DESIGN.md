## Overview
A toy operating system written in C and Lua, that runs Lua scripts as programs.

## Ideas

- Each process is a separate Lua state, and they communicate via an external IPC mechanism, probably message-passing.
