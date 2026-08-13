{
  self,
  lib,
  hosts,
  extraLibs,
  ...
}:
let
  hostForSystem = system: lib.findFirst (host: host.system == system) null (lib.attrValues hosts);
in
{
  perSystem =
    { system, ... }:
    let
      host = hostForSystem system;
      _hostExists = lib.assertMsg (host != null) "No configured host uses ${system}";
      configuration =
        if _hostExists && host.class == "nixos" then
          self.nixosConfigurations.${host.name}
        else
          self.darwinConfigurations.${host.name};
      inherit (configuration) config pkgs;
      nix-conf =
        (pkgs.formats.nixConf rec {
          inherit (config.nix) package;
          inherit (package) version;
          checkConfig = false;
        }).generate
          "nix.custom.conf"
          (
            extraLibs.attrs.pick config.nix.settings [
              "substituters"
              "trusted-public-keys"
              "trusted-substituters"
              "keep-going"
              "always-allow-substitutes"
              "narinfo-cache-negative-ttl"
            ]
          );
    in
    {
      packages = {
        inherit nix-conf;
        inherit (config.system.build) toplevel;
        ${host.name} = config.system.build.toplevel;
      };
    };
}
