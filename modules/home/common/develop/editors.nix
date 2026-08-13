{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    (jetbrains.datagrip.override { forceWayland = pkgs.stdenv.isLinux; })
    (jetbrains.idea.override { forceWayland = pkgs.stdenv.isLinux; })
  ];
}
