{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  home.packages =
    (with pkgs; [
      (lib.hiPrio uutils-coreutils-noprefix)
      (lib.hiPrio uutils-findutils)
      (lib.hiPrio (if isDarwin then diffutils else uutils-diffutils))

      gnused
      gawk
      gnutar
    ])
    ++ (
      with pkgs;
      lib.optionals isDarwin [
        gnugrep
        gzip
        gnupatch
      ]
    );
}
