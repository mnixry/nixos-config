{
  config,
  lib,
  pkgs,
  vars,
  extraLibs,
  ...
}:
{
  programs.kate = {
    enable = true;
    lsp.customServers = {
      bash = {
        command = [
          (lib.getExe pkgs.bash-language-server)
          "start"
        ];
        root = "";
        url = "https://github.com/bash-lsp/bash-language-server";
        highlightingModeRegex = "^Bash$";
      };
      nix = {
        command = [ (lib.getExe pkgs.nixd) ];
        url = "https://github.com/nix-community/nixd";
        highlightingModeRegex = "^Nix$";
        settings.nixd =
          let
            flakeRoot = extraLibs.relativeToRoot "./.";
          in
          {
            nixpkgs.expr = "import <nixpkgs> {}";
            formatting.command = [ (lib.getExe pkgs.nixfmt) ];
            options = {
              nixos.expr = ''
                let configs = (builtins.getFlake "${flakeRoot}").nixosConfigurations;
                in (builtins.head (builtins.attrValues configs)).options
              '';
              home-manager.expr = ''
                (builtins.getFlake "${flakeRoot}").nixosConfigurations.${vars.network.hostname}.options.home-manager.users.value.${vars.user.name}
              '';
            };
          };
      };
      json = {
        command = [
          (lib.getExe pkgs.vscode-json-languageserver)
          "--stdio"
        ];
        url = "https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server";
        highlightingModeRegex = "^JSON$";
      };
      yaml = {
        command = [
          (lib.getExe pkgs.yaml-language-server)
          "--stdio"
        ];
        url = "https://github.com/redhat-developer/yaml-language-server";
        highlightingModeRegex = "^YAML$";
      };
    };
    editor.font = config.programs.plasma.fonts.fixedWidth;
  };

  programs.plasma.configFile.katerc."lspclient"."AllowedServerCommandLines" =
    lib.strings.concatStringsSep ","
      (
        map ({ value, ... }: builtins.elemAt value.command 0) (
          lib.attrsToList config.programs.kate.lsp.customServers
        )
      );
}
