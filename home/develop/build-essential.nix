{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnumake
    cmake
    ninja

    (lib.hiPrio gcc_multi)
    (lib.hiPrio clang-tools)
    clang_multi
    libllvm

    bear
    patchelf
    man-pages
    man-pages-posix
  ];
}
