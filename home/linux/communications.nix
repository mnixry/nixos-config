{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixpaks.telegram
    nixpaks.feishu
    nixpaks.qq
    nixpaks.wechat
  ];
}
