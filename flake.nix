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
      nixpkgs-patched =
        let
          pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.applyPatches {
          src = pkgs.path;
          patches = [
            (pkgs.fetchpatch {
              # nixos/hardware.displaylink: fix unknown driver assertion
              url = "https://github.com/NixOS/nixpkgs/pull/491981.patch";
              hash = "sha256-vJAuizb+plx1BSV3aG8Rq5COT5fpl+xjDj0D3Z+toh0=";
            })
            (pkgs.fetchpatch {
              # mpvScripts.mpv-cheatsheet-ng: init at 0.1.0
              url = "https://github.com/NixOS/nixpkgs/pull/490264.patch";
              hash = "sha256-hwjuwx/C6a8IU9dxZa/vyWbKoM1KC6bdt5GT6aXvSnw=";
            })
            (pkgs.fetchpatch {
              # python3Packages.plotly: fix build with pytest 9 and numpy 2.4
              url = "https://github.com/NixOS/nixpkgs/pull/493409.patch";
              hash = "sha256-Euw1x2tE91R9ltnuQ4l7WNXo1vCmX6V+NLf0+s0tpzg=";
            })
          ];
        };
      inherit ((import "${nixpkgs-patched}/flake.nix").outputs { self = nixpkgs-patched; }) lib;
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
