{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    imhex
    wireshark

    gcc_multi
    clang-tools
    man-pages
    man-pages-posix

    nixd
    nixfmt-rfc-style
    nixfmt-tree

    git-filter-repo
    git-graph

    hashcat

    dive
    buildah

    android-tools
    scrcpy

    tokei
  ];

  programs.awscli = {
    enable = true;
  };
}
