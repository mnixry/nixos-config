{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    (jetbrains.datagrip.override { forceWayland = pkgs.stdenv.hostPlatform.isLinux; })
    (jetbrains.idea.override { forceWayland = pkgs.stdenv.hostPlatform.isLinux; })
  ];
}
