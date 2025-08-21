{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixpaks.telegram
    nixpaks.larksuite
    nixpaks.qq
  ];
}
