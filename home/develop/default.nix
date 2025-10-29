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
    libclang
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

    dive
    buildah
    hadolint

    android-tools
    scrcpy

    tokei
  ];

  programs.awscli = {
    enable = true;
  };
}
