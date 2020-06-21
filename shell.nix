{ pkgs ? import <nixpkgs> {} }:

let
  # NOTE: Currently on my `uefi-bugs` branch.
  zigCustom = pkgs.zig.overrideAttrs (oldAttrs: rec {
      src = ../zig;
    });
in pkgs.mkShell {
  buildInputs = with pkgs; [
    zigCustom
    qemu
    binutils
  ];

  OVMF_PATH = "${pkgs.OVMF.fd}/FV/OVMF.fd";
}
