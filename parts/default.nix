{ ... }:
{
  imports = [
    ../modules/flake/host-options.nix
    ../modules/flake/hosts.nix
    ./inventory.nix
    ./packages.nix
  ];
}
