{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    jetbrains.datagrip
    jetbrains.idea
  ];
}
