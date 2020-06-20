{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    qemu
  ];

  OVMF_PATH = "${pkgs.OVMF.fd}/FV/OVMF.fd";
}
