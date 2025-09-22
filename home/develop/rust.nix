{ pkgs, ... }:
{
  home.packages = with pkgs; [ rust-bin.stable.latest.complete ];
}
