{
  config,
  pkgs,
  ...
}:
{
  # Darwin-specific packages
  home.packages = (
    with pkgs;
    [
      docker-client
      docker-compose
      docker-credential-helpers

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
      (raycast.overrideAttrs (old: {
        # Remove the self-updater's launchd plists so a newer Raycast can
        # never be installed and migrate the local databases ahead of the
        # nix-pinned version.
        postInstall = (old.postInstall or "") + ''
          rm -f "$out/Applications/Raycast.app/Contents/Library/LaunchAgents/Updater.plist" \
                "$out/Applications/Raycast.app/Contents/Library/LaunchDaemons/Updater-Daemon.plist"
        '';
      }))
    ]
  );

  # Home Manager defaults to macOS's built-in man on Darwin. Use mandoc so
  # both man and the bat-extras batman wrapper can resolve Nix manual pages.
  programs.man = {
    package = pkgs.mandoc;
    man-db.enable = false;
    mandoc.enable = true;
  };

  programs.docker-cli = {
    enable = true;
    configDir = "${config.xdg.configHome}/docker";
    settings.credsStore = "osxkeychain";
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
