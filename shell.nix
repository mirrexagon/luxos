{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    qemu
  ];

  OVMF_DIR = "${pkgs.OVMF}";
}
