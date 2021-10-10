/*
References:
- https://github.com/sifive/freedom-e-sdk/blob/f6d42e1c21a2dde5cd942be0e7f68f8dfff941d1/bsp/sifive-hifive1-revb/metal.default.lds
- https://github.com/sgmarz/osblog/blob/f9572be05addbea25ae5c35aca3d6846e60417de/risc_v/src/lds/virt.lds
- https://wiki.osdev.org/HiFive-1_Bare_Bones
- https://interrupt.memfault.com/blog/how-to-write-linker-scripts-for-firmware
- About the bootloader: https://forums.sifive.com/t/bootloader-restore/2429 https://forums.sifive.com/t/default-bootloader-kernel/2630/3
- https://sourceware.org/binutils/docs/ld/Scripts.html
*/

OUTPUT_ARCH("riscv")

ENTRY(_start)

/*
w = writable
x = executable
a = allocatable
r = read-only
i = initialized
! = invert flags after this symbol

Mappings from FE310-G002 manual, chapter 4 (Memory Map)
*/
MEMORY {
    ram (wa!rx) : ORIGIN = 0x80000000, LENGTH = 16K

    /*
    The memory-mapped flash region is 512 MiB large and starts at 0x20000000,
    but the HiFive1 Rev B comes with a bootloader there that runs and
    then jumps to 0x20010000.

    From the HiFive1 Rev B Getting started Guide v1.2:

        The HiFive1 Rev B Board is shipped with a modifiable boot loader at the begnning of SPI Flash
        (0x20000000). At the end of this program’s execution the core jumps to the main user portion of
        code at 0x20010000. This program is designed to allow quick boot, but also a “safe” reboot
        option if a “bad” program is flashed into the HiFive1’s SPI Flash. A “bad” program is one which
        makes it impossible for the programmer to communicate with the HiFive1 Rev B. For example, a
        program which disables FE310’s active clock, or which puts the FE310 to sleep with no way of
        waking it up. Bad programs can always be restarted using the RESET button, and using the
        “safe” bootloader can be halted before they perform any unsafe behavior.

    To avoid overwriting the bootloader, instead of doing:

    flash (rxa!w) : ORIGIN = 0x20000000, LENGTH = 512M

    we instead start at 0x20010000.

    Note that the actual flash chip is 4 MB (32 Mbit) large, so we also take
    that into account here.
    */
    flash (rxa!w) : ORIGIN = 0x20010000, LENGTH = (4M - 0x10000)
}

SECTIONS {
    /*
    At the end of each output section:
        > = VMA (virtual memory address)
        AT> = LMA (load memory address)

    Each section in an object file has a name and a size. Most sections also have an
    associated block of data, known as the section contents. A section may be marked
    as loadable, which means that the contents should be loaded into memory when the
    output file is run. A section with no contents may be allocatable, which means
    that an area in memory should be set aside, but nothing in particular should be
    loaded there (in some cases this memory must be zeroed out). A section which
    is neither loadable nor allocatable typically contains some sort of debugging
    information.

    Every loadable or allocatable output section has two addresses. The first
    is the VMA, or virtual memory address. This is the address the section will
    have when the output file is run. The second is the LMA, or load memory
    address. This is the address at which the section will be loaded. In most
    cases the two addresses will be the same. An example of when they might be
    different is when a data section is loaded into ROM, and then copied into
    RAM when the program starts up (this technique is often used to initialize
    global variables in a ROM based system). In this case the ROM address would
    be the LMA, and the RAM address would be the VMA.

    https://sourceware.org/binutils/docs/ld/Basic-Script-Concepts.html
    https://sourceware.org/binutils/docs/ld/Output-Section-LMA.html
    */

    .text :
    {
        /*
        The entry point must be where the bootloader jumps to. We set the start
        of our flash region to that point in the MEMORY section.
        */
        *(.text.start)
        *(.text .text.*)
    } >flash AT>flash
    /*
    Code (.text) doesn't need to be writable and is just read/executed from flash.
    */

    .rodata : {
        *(.rodata .rodata.*)
    } >flash AT>flash
    /*
    Read-only data (.rodata) doesn't need to be writable and is also just read from flash.
    */

    __data_source_start = LOADADDR(.data);
    __data_source_end = LOADADDR(.data) + SIZEOF(.data);
    __data_target_start = ADDR(.data);
    __data_target_end = ADDR(.data) + SIZEOF(.data);

    .data : {
        *(.sdata .sdata.* .data .data.*)
    } >ram AT>flash
    /*
    Modifiable data (.data) does need to be writable and so needs be in RAM, but
    has initial values in flash that need to be loaded. Thus the LMA is in flash
    but the VMA is in RAM.
    */

    __bss_source_start = LOADADDR(.bss);
    __bss_source_end = LOADADDR(.bss) + SIZEOF(.bss);
    __bss_target_start = ADDR(.bss);
    __bss_target_end = ADDR(.bss) + SIZEOF(.bss);

    .bss : {
        *(.sbss .sbss.* .bss .bss.*)
    } >ram AT>ram
    /*
    Zero-initialised data (.bss) does need to be writable but doesn't need
    anything loaded from flash. So it is entirely in RAM.
    */

    __stack_size = 1K;

    .stack ORIGIN(ram) + LENGTH(ram) - __stack_size : {
        /*
        The stack pointer needs to be aligned to 16 bytes and can initially
        point to a non-existent word (eg. just past the end of RAM), as per the
        RISC-V calling convention.
        TODO: Add reference to ELF/ABI/calling convention document.
        */
        __initial_stack_pointer = ADDR(.stack) + __stack_size;
    } >ram AT>ram
}
