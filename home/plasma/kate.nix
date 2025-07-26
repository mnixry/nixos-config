{
  lib,
  pkgs,
  vars,
  extraLibs,
  ...
}:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  programs.kate = {
    enable = true;
    package = pkgs.kdePackages.kate.overrideAttrs (_: {
      version = "git";
      src = builtins.fetchGit {
        url = "https://invent.kde.org/utilities/kate.git";
        rev = "762d7ad454630a511b67f5bf9705e712e3821b62";
      };
    });
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
