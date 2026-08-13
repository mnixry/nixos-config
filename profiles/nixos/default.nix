{
  base = [
    ../../pkgs
    ../../modules/nixos/system/default.nix
  ];
  workstation = [
    ../../modules/nixos/services/default.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/desktop-managers.nix
    ../../modules/nixos/user.nix
  ];
  custom-kernel = [ ../../modules/nixos/system/kernel.nix ];
  ephemeral-root = [ ../../modules/nixos/preservation.nix ];
}
