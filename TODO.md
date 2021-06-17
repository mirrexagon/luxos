- https://interrupt.memfault.com/blog/how-to-write-linker-scripts-for-firmwareA
- https://elinux.org/Device_Tree_Usage

# Booting with U-Boot and OpenSBI
- https://github.com/riscv/opensbi/blob/master/docs/platform/qemu_virt.md
- https://github.com/u-boot/u-boot/blob/master/doc/board/emulation/qemu-riscv.rst

We want to do it this way and not just start the kernel in machine mode to be portable across platforms.

"The SBI allows supervisor-mode (S-mode or VS-mode) software to be portable across all RISC-V implementations by defining an abstraction for platform (or hypervisor) specific functionality."
