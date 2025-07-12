{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    daeuniverse.url = "github:daeuniverse/flake.nix";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      # Please replace my-nixos with your hostname
      nixosConfigurations.mix-laptop-21tl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./configuration.nix
          inputs.daeuniverse.nixosModules.dae
          inputs.daeuniverse.nixosModules.daed
          inputs.chaotic.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.home-manager.nixosModules.home-manager
          inputs.preservation.nixosModules.default
        ];
      };
    };
}
