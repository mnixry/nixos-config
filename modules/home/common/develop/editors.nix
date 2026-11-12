{ pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      code-cursor
      jetbrains.datagrip
      jetbrains.idea
    ])
    ++ [
      (if pkgs.stdenv.hostPlatform.isLinux then pkgs.zed-editor else pkgs.brewCasks.zed)
    ];
}
