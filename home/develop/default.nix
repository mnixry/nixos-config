{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    gcc_multi
    clang-tools

    nixd
    nixfmt-rfc-style
    nixfmt-tree
    alejandra

    dive

    android-tools
    scrcpy

    tokei
  ];

  programs.awscli = {
    enable = true;
  };
}
