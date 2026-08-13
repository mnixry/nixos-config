{ pkgs, lib, ... }:
{
  imports = [
    ./docker.nix
    ./virt-manager.nix
  ];

  boot.binfmt = {
    preferStaticEmulators = true;
    emulatedSystems = lib.filter (
      system:
      pkgs.stdenv.hostPlatform.system != system
      && (lib.systems.elaborate { inherit system; }).emulatorAvailable pkgs.pkgsStatic
    ) (lib.attrNames (import "${pkgs.path}/nixos/lib/binfmt-magics.nix"));
  };
}
