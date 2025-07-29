{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      flake = false;
    };
    # https://github.com/nix-community/preservation/pull/16
    preservation.url = "github:nix-community/preservation/default-user-ownership";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      vars = import ./vars;
      specialArgs = {
        inherit inputs;
        inherit vars;
        extraLibs = import ./libs { inherit (inputs.nixpkgs) lib; };
      };
    in
    {
      nixosConfigurations."${vars.network.hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [
          ./system
          ./services
          ./desktop
          ./preservation.nix
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${vars.user.name}" = import ./home;
          }
        ];
      };
    };
}
