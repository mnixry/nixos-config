{ pkgs, ... }:
{
  home.packages = [
    (pkgs.python3.withPackages (
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
      ]
    ))
    pkgs.pypy3
  ];

  programs.ruff = {
    enable = true;
  };

  programs.pdm = {
    enable = true;
    package = pkgs.pdm;
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
