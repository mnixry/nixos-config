{ pkgs, lib, ... }:
let
  inherit (pkgs) rust-bin;
  rust = rust-bin.stable.latest.complete.override {
    targets = [ "x86_64-unknown-linux-musl" ];
  };
  rustfmt = rust-bin.selectLatestNightlyWith (toolchain: toolchain.rustfmt);
in
{
  home.packages = [
    (lib.hiPrio rustfmt)
    rust
  ]
  ++ (with pkgs; [
    cargo-pgo
    cargo-zigbuild
    cargo-edit
    cargo-nextest
    zig
    taplo
  ]);
}
