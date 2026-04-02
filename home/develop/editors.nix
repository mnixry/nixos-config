{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    (jetbrains.datagrip.override { forceWayland = true; })
    (jetbrains.idea.override { forceWayland = true; })
  ];
  programs.vscode.enable = true;
}
