{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ((zig.overrideAttrs (oldAttrs: {
      version = "git";

      src = fetchFromGitHub {
        owner = "ziglang";
        repo = oldAttrs.pname;
        rev = "a18bf7a7bfa4e8c32aa25295cfa1ca768e5f5b74";
        hash = "sha256-Hfl1KKtGcopMrn+U9r0/qr/wReWJIgb8+IgwMoguv/0=";
      };
    })).override {
      llvmPackages = llvmPackages_13;
    })

    qemu

    gdb
    pkgs.pkgsCross.riscv64.buildPackages.binutils
  ]
  ++ lib.optional (pkgs ? ugdb) ugdb
  ++ lib.optional (pkgs ? segger-jlink) segger-jlink;
}
