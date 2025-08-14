{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    gcc_multi
    clang-tools
  ];

  programs.awscli = {
    enable = true;
  };
}
