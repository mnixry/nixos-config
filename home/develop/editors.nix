{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    code-cursor
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    (jetbrains.datagrip.override { forceWayland = true; })
    (jetbrains.idea.override { forceWayland = true; })
  ];
  programs.vscode.enable = true;
}
