{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (rust-bin.stable.latest.complete.override {
      targets = [ "x86_64-unknown-linux-musl" ];
    })
    cargo-pgo
    cargo-zigbuild
    zig
  ];
}
