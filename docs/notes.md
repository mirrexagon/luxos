## Design notes
- Each process is a separate Lua state, and they communicate via an external IPC mechanism, probably message passing. Check out effil for an example implementation of message passing.
- All scripts run in kernel mode. Permissions are done by denying scripts access to functions/modules.

### Ideas
Have the concept of resources that can be exclusively acquired, eg. Whole Uart, I2C bus, single I2C device - some controller process could acquire a peripheral and be a driver for it, other processes communicate with it via IPC

Processes can create and expose resources for other processes to take, eg. I2C driver acquires I2C bus resource and in turn exposes the ability to create and acquire a resource for a specific device on the bus - request would probably be done via channels/messages.

Resources keep track of provider (eg. Kernel provides low level peripherals, processes can provide virtual resources like a single I2C device) and owner (which process has exclusive access to the resource) - eg. Provider ID 0 is the kernel, otherwise is process ID

Scheme and path system like Redox?

## Booting with U-Boot and OpenSBI
- https://github.com/riscv/opensbi/blob/master/docs/platform/qemu_virt.md
- https://github.com/u-boot/u-boot/blob/master/doc/board/emulation/qemu-riscv.rst

We want to do it this way and not just start the kernel in machine mode to be portable across platforms.

"The SBI allows supervisor-mode (S-mode or VS-mode) software to be portable across all RISC-V implementations by defining an abstraction for platform (or hypervisor) specific functionality."

See Early Boot in Linux for expected state: https://www.sifive.com/blog/all-aboard-part-6-booting-a-risc-v-linux-kernel

## Nice panics in Zig bare metal
https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html
