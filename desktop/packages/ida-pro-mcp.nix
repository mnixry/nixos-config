{
  python3,
  fetchFromGitHub,
  installShellFiles,
}:
let
  py = python3 // {
    pkgs = python3.pkgs.overrideScope (
      final: prev: {
        mcp = prev.mcp.overrideAttrs (prev: rec {
          version = "1.25.0";
          src = prev.src.override {
            tag = "v${version}";
            hash = "sha256-fSQCvKaNMeCzguM2tcTJJlAeZQmzSJmbfEK35D8pQcs=";
          };
        });
      }
    );
  };
  inherit (py.pkgs) buildPythonApplication;
in
buildPythonApplication rec {
  pname = "ida-pro-mcp";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "mrexodia";
    repo = "ida-pro-mcp";
    tag = version;
    hash = "sha256-abH6i/Xr3P3/gP8L151FZBU9ovp/olFWwKenPz7BuF8=";
  };

  pyproject = true;
  nativeBuildInputs = [ installShellFiles ];
  build-system = with py.pkgs; [ setuptools ];
  dependencies = with py.pkgs; [ mcp ];

  meta.mainProgram = "ida-pro-mcp";
}
