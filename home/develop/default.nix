{
  pkgs,
  lib,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    (lib.hiPrio gcc_multi)
    (lib.hiPrio clang-tools)
    clang_multi
    libllvm
    bear
    patchelf
    man-pages
    man-pages-posix

    nixd
    nixfmt-rfc-style
    nixfmt-tree

    git-filter-repo
    git-graph

    hashcat
    imhex
    wireshark
    bpftrace
    ida-pro

    dive
    buildah
    hadolint

    android-tools
    scrcpy

    tokei
    graphviz
    ffmpeg
    caddy
  ];

  programs.awscli = {
    enable = true;
  };
}
