{ pkgs, lib, ... }:
let
  hasRustOverlay = pkgs ? rust-bin;
  rust = if hasRustOverlay then
    pkgs.rust-bin.stable.latest.complete.override {
      targets = lib.optionals pkgs.stdenv.isLinux [ "x86_64-unknown-linux-musl" ];
    }
  else
    pkgs.rustc;
  rustfmt = if hasRustOverlay then
    pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.rustfmt)
  else
    pkgs.rustfmt;
in
{
  home.packages = lib.optionals hasRustOverlay [
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
