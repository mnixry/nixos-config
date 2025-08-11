{ inputs, ... }:
let
  inherit (inputs) nixpak;
  wrapper =
    pkgs: path:
    pkgs.callPackage path {
      inherit (nixpak) nixpakModules;
      mkNixPak = nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };
    };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      nixpaks = {
        telegram = wrapper prev ./nixpaks-telegram.nix;
        larksuite = wrapper prev ./nixpaks-larksuite.nix;
      };
    })
  ];
}
