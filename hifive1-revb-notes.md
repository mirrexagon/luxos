Using JLinkExe (J-Link Commander), `SaveBin reset.bin, 0x1000, 0x1C` contents matches the reset vector instructions as described in the FE310-G002 manual v1p1 chapter 5.1.

Disassembly with `riscv64-unknown-linux-gnu-objdump -b binary -m riscv:rv32 -D reset.bin`

Thus SaveBin saves from memory addresses, not flash addresses.
