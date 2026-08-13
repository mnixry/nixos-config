{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      (lib.hiPrio clang-tools)
      gnumake
      cmake
      ninja

      bear
      man-pages
      man-pages-posix
    ]
    ++ lib.optionals stdenv.isLinux [
      (lib.hiPrio gcc_multi)
      libllvm
      clang_multi
      llvmPackages.bolt
      patchelf
    ]
    ++ lib.optionals stdenv.isDarwin [
      (lib.hiPrio stdenv.cc)
      gcc
    ];
}
