{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      flake = false;
    };
    preservation.url = "github:nix-community/preservation";
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
    niks3 = {
      url = "github:Mic92/niks3";
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
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      vars = import ./vars;
      extraLibs = import ./libs { inherit lib; };
      specialArgs = { inherit inputs vars extraLibs; };
      inherit (self.nixosConfigurations."${vars.network.hostname}") config pkgs;
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      nixosConfigurations."${vars.network.hostname}" = lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./system
          ./services
          ./desktop
          ./preservation.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${vars.user.name}" = import ./home;
          }
        ];
      };
      packages.${system} = {
        nix-conf =
          (pkgs.formats.nixConf rec {
            inherit (config.nix) package;
            inherit (package) version;
            checkConfig = false;
          }).generate
            "nix.custom.conf"
            (
              extraLibs.attrs.pick config.nix.settings [
                "experimental-features"
                "substituters"
                "trusted-public-keys"
                "trusted-substituters"
                "use-cgroups"
                "keep-going"
                "always-allow-substitutes"
                "narinfo-cache-negative-ttl"
              ]
            );
        inherit (config.system.build) toplevel;
        inherit pkgs;
      };
    };
}
