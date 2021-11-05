{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ((zig.overrideAttrs (oldAttrs: {
      version = "git";

      src = fetchFromGitHub {
        owner = "ziglang";
        repo = oldAttrs.pname;
        rev = "e97feb96e4daf7d53538c9c8773d50459a59e5ee";
        hash = "sha256-d35Ffobsi/RiZ0V9/I8gFPZxv8nrekQWhYX7tTZdn7w=";
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
