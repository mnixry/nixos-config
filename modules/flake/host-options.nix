{ lib, ... }:
let
  hostModule = {
    options = {
      class = lib.mkOption {
        type = lib.types.enum [
          "nixos"
          "darwin"
        ];
      };
      name = lib.mkOption { type = lib.types.str; };
      system = lib.mkOption { type = lib.types.str; };
      stateVersion = lib.mkOption { type = lib.types.either lib.types.str lib.types.int; };
      homeStateVersion = lib.mkOption { type = lib.types.str; };
      user = lib.mkOption { type = lib.types.attrs; };
      hardware = lib.mkOption {
        type = lib.types.attrs;
        default = { };
      };
      profiles = {
        nixos = lib.mkOption {
          type = lib.types.listOf (lib.types.listOf lib.types.deferredModule);
          default = [ ];
        };
        darwin = lib.mkOption {
          type = lib.types.listOf (lib.types.listOf lib.types.deferredModule);
          default = [ ];
        };
        home = lib.mkOption {
          type = lib.types.listOf (lib.types.listOf lib.types.deferredModule);
          default = [ ];
        };
      };
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
      };
    };
  };
in
{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule hostModule);
    default = { };
  };
}
