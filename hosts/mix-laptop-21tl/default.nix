let
  profiles = {
    nixos = import ../../profiles/nixos;
    home = import ../../profiles/home;
  };
in
{
  class = "nixos";
  system = "x86_64-linux";
  stateVersion = "26.05";
  homeStateVersion = "26.05";

  user = {
    name = "mix";
    fullName = "HexMix";
    initialHashedPassword = "$gy$j9T$5Oax3RFzgwFa0qQdVLktl.$pKJKEnCVf6TBcJZL3cWV7yIxUDhFhj9iYJgHC5ujzH0";
  };

  hardware = {
    bootDevice = "/dev/disk/by-partuuid/c52e2372-9927-46e2-b626-d1b658ab622a";
    rootDevice = "/dev/disk/by-uuid/febcf993-9a92-4ed9-8bb2-8df8bc810af6";
    luksName = "system";
  };

  profiles = {
    nixos = with profiles.nixos; [
      base
      workstation
      custom-kernel
      ephemeral-root
    ];
    home = with profiles.home; [
      common
      linux
    ];
  };

  modules = [
    ./hardware.nix
    ./storage.nix
    ./secure-boot.nix
  ];
}
