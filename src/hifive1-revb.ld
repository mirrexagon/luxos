/*
References:
- https://github.com/sifive/freedom-e-sdk/blob/f6d42e1c21a2dde5cd942be0e7f68f8dfff941d1/bsp/sifive-hifive1-revb/metal.default.lds
- https://github.com/sgmarz/osblog/blob/f9572be05addbea25ae5c35aca3d6846e60417de/risc_v/src/lds/virt.lds
*/

OUTPUT_ARCH( "riscv" )

ENTRY( _start )

/*
w = writable
x = executable
a = allocatable
r = read-only
i = initialized
! = invert flags after this symbol

Mappings from FE310-G002 manual, chapter 4 (Memory Map)
*/
MEMORY
{
    ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 16K

    /*
    The memory-mapped flash region is 512 MiB large and starts at 0x20000000,
    but the HiFive1 Rev B comes with a bootloader there that runs and
    eventually jumps to 0x20010000. To avoid overwriting the bootloader,
    instead of doing:

    flash (rxai!w) : ORIGIN = 0x20000000, LENGTH = 512M

    we instead start at 0x20010000.

    Note that the actual flash chip is 4 MB (32 Mbit) large, so we also take
    that into account here.
    */
    flash (rxai!w) : ORIGIN = 0x20010000, LENGTH = (4M - 0x10000)
}

PHDRS
{
}

SECTIONS
{
    .text :
    {
        /*
        The entry point must be at the start of flash (well, technically at
        0x10000 into flash, where the bootloader jumps to. We set that up in the
        MEMORY section.
        */
        *(.text.start)
        *(.text .text.*)
    } >flash AT>flash :flash
}
