{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common
  ];

  # Darwin-specific packages
  home.packages = (
    with pkgs;
    [
      docker-client
      docker-compose

      # macOS softwares
      xcbuild
      nano
      (ice-bar.overrideAttrs rec {
        version = "0.11.13-dev.2";
        src = fetchurl {
          url = "https://github.com/jordanbaird/Ice/releases/download/${version}/Ice.zip";
          hash = "sha256-wbuqcfYev+Xuko95CvYJY6nyAjZNY/eNLGs+xRBc9KA=";
        };
      })
      alt-tab-macos
      powertop-macos
      spotify
      raycast
    ]
  );

  programs.docker-cli = {
    enable = true;
    configDir = "${config.xdg.configHome}/docker";
  };

  services.colima = {
    enable = true;
    profiles.default = {
      isService = true;
      isActive = true;
      setDockerHost = true;
      settings = {
        runtime = "docker";
        arch = "host";

        vmType = "vz";

        mountType = "virtiofs";
        mounts = [ ];

        cpu = 4;
        memory = 4;
        disk = 100;

        kubernetes.enabled = false;
        portForwarder = "grpc";
      };
    };
  };
}
