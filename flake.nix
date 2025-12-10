{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      flake = false;
    };
    preservation.url = "github:nix-community/preservation";
    determinate-nix = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/3.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
      inherit (nixpkgs) lib;
      vars = import ./vars;
      specialArgs = {
        inherit inputs;
        inherit vars;
        extraLibs = import ./libs { inherit lib; };
      };
      forAllSystems = lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      nixosConfigurations."${vars.network.hostname}" = nixpkgs.lib.nixosSystem {
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
      packages = forAllSystems (
        system:
        let
          inherit (self.nixosConfigurations."${vars.network.hostname}") config;
          inherit (nixpkgs) lib;
          pkgs = import nixpkgs { inherit system; };
          pick = set: names: with lib; filterAttrs (name: _: elem name names) set;
          toNixConf =
            (pkgs.formats.nixConf rec {
              package = config.nix.package.out;
              inherit (package) version;
            }).generate;
        in
        {
          nix-conf = toNixConf "nix.custom.conf" (
            pick config.nix.settings [
              "eval-cores"
              "experimental-features"
              "lazy-trees"
              "substituters"
              "trusted-public-keys"
              "trusted-substituters"
            ]
          );
          inherit (config.system.build) toplevel;
        }
      );
    };
}
