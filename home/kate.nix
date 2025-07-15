{
  lib,
  pkgs,
  vars,
  extraLibs,
  ...
}:
{
  home.packages = with pkgs; [
    kdePackages.kate
    nixd
    nixfmt-rfc-style
  ];

  programs.kate = {
    enable = true;
    lsp.customServers = {
      nix = {
        command = [ "nixd" ];
        url = "https://github.com/nix-community/nixd";
        highlightingModeRegex = "^Nix$";
        settings.nixd = {
          nixpkgs.expr = "import <nixpkgs> {}";
          formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
          options =
            let
              flakeRoot = extraLibs.relativeToRoot "./.";
            in
            {
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
    };
  };
}
