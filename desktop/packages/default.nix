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
      safeBind = sloth: realdir: mapdir: [
        (sloth.mkdir (sloth.concat' sloth.appDataDir realdir))
        (sloth.concat' sloth.homeDir mapdir)
      ];
    };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      nixpaks = {
        telegram = wrapper prev ./nixpaks-telegram.nix;
      };
    })
  ];
}
