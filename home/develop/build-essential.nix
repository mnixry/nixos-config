{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    gnumake
    cmake
    ninja

    (lib.hiPrio clang-tools)
    libllvm
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    (lib.hiPrio gcc_multi)
    clang_multi
    llvmPackages.bolt
    bear
    patchelf
    man-pages
    man-pages-posix
  ];
}
