{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig

    qemu

    gdb
    pkgs.pkgsCross.riscv64.buildPackages.binutils
  ]
  ++ lib.optional (pkgs ? ugdb) ugdb
  ++ lib.optional (pkgs ? segger-jlink) segger-jlink;
}
