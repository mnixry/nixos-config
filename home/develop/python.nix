{ pkgs, lib, ... }:
let
  mkNixLDwrappedPackage =
    package:
    let
      binOverride = pkgs.symlinkJoin {
        name = "nix-ld-override-${package.name}";
        paths =
          map
            (
              name:
              pkgs.writeShellScriptBin name ''
                export LD_LIBRARY_PATH="''${NIX_LD_LIBRARY_PATH}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
                exec '${lib.getExe' package name}' "$@"
              ''
            )
            (
              builtins.attrNames (
                lib.attrsets.filterAttrs (path: _type: _type != "directory") (builtins.readDir "${package}/bin/")
              )
            );
      };
    in
    pkgs.buildEnv {
      inherit (package) name meta passthru;
      paths = [
        (lib.hiPrio binOverride)
        package
      ];
    };
in
{
  home.packages = [
    (mkNixLDwrappedPackage (
      pkgs.python3.withPackages (
        ps: with ps; [
          pipx
          ptpython
          virtualenv

          numpy
          pandas

          requests
          httpx
          rich

          sympy
          cryptography
          pycryptodome
          gmpy2

          pwntools
          ropper
        ]
      )
    ))
    (mkNixLDwrappedPackage pkgs.pypy3)
  ]
  ++ (with pkgs; [ ruff ]);

  programs.pdm = {
    enable = true;
    settings = {
      venv.backend = "venv";
    };
  };

  programs.uv = {
    enable = true;
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
    };
  };

  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
}
