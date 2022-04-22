{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ((zig.overrideAttrs (oldAttrs: {
      version = "git";

      # Version with fix for packed struct size issues.
      # https://github.com/ziglang/zig/pull/11279
      src = fetchFromGitHub {
        owner = "ziglang";
        repo = oldAttrs.pname;
        rev = "cf20b97b713d992d84fdd8935ef935f61ed6d747";
        hash = "sha256-j9/+TkjAy6H4saltz6l5s0BrHfmP56LDocOD4tP2RmI=";
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
