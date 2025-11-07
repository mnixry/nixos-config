{
  config,
  lib,
  pkgs,
  ...
}:
let
  description = "Home Manager module for the Ghidra, ${pkgs.ghidra.meta.description}";
  inherit (lib) types;
  cfg = config.programs.ghidra;
  settingsFormat = pkgs.formats.javaProperties { };
in
{
  options = {
    programs.ghidra = {
      enable = lib.mkEnableOption description;
      package = lib.mkOption {
        type = types.package;
        default = pkgs.ghidra;
        description = "Package providing Ghidra.";
      };
      extensions = lib.mkOption {
        type = types.nullOr (types.functionTo (types.listOf types.package));
        default = null;
        example = lib.literalExpression ''
          p: with p; [ ghidra-scripts ]
        '';
        description = "Extensions for Ghidra.";
      };
      waylandSupport = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Enable Wayland support for Ghidra.";
      };
      preferences = lib.mkOption {
        type = types.submodule { freeformType = settingsFormat.type; };
        default = { };
        description = "Preferences for Ghidra.";
      };
    };
  };
  config = lib.mkIf cfg.enable (
    let
      ghidra = lib.pipe cfg.package (
        (lib.optionals cfg.waylandSupport [
          (super: super.override { openjdk21 = pkgs.jetbrains.jdk; })
          (
            super:
            super.overrideAttrs (prev: {
              postPatch = prev.postPatch + ''
                sed -i -E '/^VMARGS.*=-D(sun\.java2d\.|awt\.).*/s/^/#/' Ghidra/RuntimeScripts/Common/support/launch.properties
                echo "VMARGS=-Dawt.toolkit.name=WLToolkit" >> Ghidra/RuntimeScripts/Common/support/launch.properties
                echo "VMARGS=-Dsun.java2d.vulkan=True" >> Ghidra/RuntimeScripts/Common/support/launch.properties
              '';
            })
          )
        ])
        ++ (lib.optionals (cfg.extensions != null) [
          (super: super.withExtensions cfg.extensions)
        ])
      );
    in
    {
      home.packages = [ ghidra ];
      xdg.configFile."ghidra/${cfg.package.distroPrefix}/preferences".source =
        settingsFormat.generate "config.properties" cfg.preferences;
    }
  );
}
