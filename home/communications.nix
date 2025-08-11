{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixpaks.telegram
  ];
}
