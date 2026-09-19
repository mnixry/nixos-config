{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      treefmt = {
        projectRootFile = ".git/config";
        programs.nixf-diagnose = {
          enable = true;
          autoFix = true;
        };
        programs.nixfmt.enable = true;
        programs.yamlfmt.enable = true;
        programs.actionlint.enable = true;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.treefmt.build.devShell ];
      };
    };
}
