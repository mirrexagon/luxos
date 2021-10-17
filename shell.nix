{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ((zig.overrideAttrs (oldAttrs: {
      version = "git";

      src = fetchFromGitHub {
        owner = "ziglang";
        repo = oldAttrs.pname;
        rev = "0536c25578fa15e2326eb1061f6db61d6ad3cd65";
        hash = "sha256-xxb3jSvmrGHm7KiEo9CiHNxNmT0C+wiyJp9pYwKQBgo=";
      };
    })).override {
      llvmPackages = llvmPackages_13;
    })

    qemu

    segger-jlink

    ugdb
    gdb
    pkgs.pkgsCross.riscv64.buildPackages.binutils
  ];
}
