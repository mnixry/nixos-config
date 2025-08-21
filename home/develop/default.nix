{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    gcc_multi
    clang-tools

    nixd
    nixfmt-rfc-style

    dive
  ];

  programs.awscli = {
    enable = true;
  };
}
