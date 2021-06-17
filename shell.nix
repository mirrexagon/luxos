{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    qemu

    pkgs.pkgsCross.riscv64.buildPackages.binutils
  ];
}
