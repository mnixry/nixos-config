{
  lib,
  config,
  inputs,
  vars,
  extraLibs,
  ...
}:
let
  cfg = config.hosts;
  specialArgsFor = name: host: {
    inherit extraLibs inputs vars;
    inherit host;
  };
  flattenProfiles = builtins.concatLists;

  homeManagerModule = name: host: platformModule: {
    imports = [ platformModule ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = specialArgsFor name host;
      users.${host.user.name}.imports = flattenProfiles host.profiles.home;
    };
  };

  mkNixos =
    name: host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgsFor name host;
      modules =
        flattenProfiles host.profiles.nixos
        ++ host.modules
        ++ [
          {
            networking.hostName = name;
            nixpkgs.hostPlatform = lib.mkDefault host.system;
            system.stateVersion = lib.mkDefault host.stateVersion;
          }
          (homeManagerModule name host inputs.home-manager.nixosModules.home-manager)
        ];
    };

  mkDarwin =
    name: host:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = specialArgsFor name host;
      modules =
        flattenProfiles host.profiles.darwin
        ++ host.modules
        ++ [
          {
            nixpkgs.hostPlatform = lib.mkDefault host.system;
            system.stateVersion = lib.mkDefault host.stateVersion;
          }
          (homeManagerModule name host inputs.home-manager.darwinModules.home-manager)
        ];
    };

  hostsOfClass = class: lib.filterAttrs (_: host: host.class == class) cfg;
in
{
  config.flake = {
    nixosConfigurations = lib.mapAttrs mkNixos (hostsOfClass "nixos");
    darwinConfigurations = lib.mapAttrs mkDarwin (hostsOfClass "darwin");
  };
}
