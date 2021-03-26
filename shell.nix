{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    qemu
    binutils
  ];

  OVMF_PATH = "${pkgs.OVMF.fd}/FV/OVMF.fd";
}
