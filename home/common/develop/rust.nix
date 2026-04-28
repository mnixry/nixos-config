{ pkgs, lib, ... }:
let
  rust = pkgs.rust-bin.stable.latest.complete.override {
    targets = lib.optionals pkgs.stdenv.isLinux [ "x86_64-unknown-linux-musl" ];
  };

  rustfmt = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.rustfmt);
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
