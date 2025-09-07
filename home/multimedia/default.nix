{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    nixpaks.spotify
    netease-cloud-music-gtk
  ];
}
