{ pkgs, lib, ... }:
let
  mkNixLDwrappedPackage =
    package:
    if pkgs.stdenv.isLinux then
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
      }
    else
      package;

  pythonPackages =
    ps: with ps; [
      pip
      ptpython
      virtualenv

      numpy
      pandas
      scipy
      pillow

      requests
      httpx
      rich

      sympy
      cryptography
      pycryptodome
      gmpy2

      pwntools
      ropper
    ];
in
{
  home.packages = with pkgs; [
    (mkNixLDwrappedPackage (python3.withPackages pythonPackages))
    (mkNixLDwrappedPackage pypy3)
    ruff
  ];

  programs.pdm = {
    enable = true;
    package = pkgs.pkgsStable.pdm;
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
