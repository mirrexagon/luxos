{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ((zig.overrideAttrs (oldAttrs: {
      version = "git";

      # Version with fix for packed struct size issues.
      # https://github.com/ziglang/zig/pull/11279
      src = fetchFromGitHub {
        owner = "igor84";
        repo = oldAttrs.pname;
        rev = "109e730c8ccdfe144f568f232578ab600ef4f33c";
        hash = "sha256-fEeO6g7bCvpiNJWkQdBVbBCr42giknuZndHowPq1BgU=";
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
