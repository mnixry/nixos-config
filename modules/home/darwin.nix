{
  config,
  pkgs,
  ...
}:
{
  # Darwin-specific packages
  home.packages =
    (with pkgs; [
      docker-client
      docker-compose
      docker-credential-helpers

      # macOS softwares
      xcbuild
      nano
      powertop-macos
      lark-cli
    ])
    ++ (with pkgs.brewCasks; [
      kate
      alt-tab
      bitwarden
      pkgs.brewCasks."virtualbuddy@beta"
      pkgs.brewCasks."jordanbaird-ice@beta"
      (raycast.overrideAttrs (old: {
        # Remove the self-updater's launchd plists so a newer Raycast can
        # never be installed and migrate the local databases ahead of the
        # nix-pinned version.
        # Appended to installPhase, not postInstall: brew-nix's custom
        # installPhase never runs `runHook postInstall`, so a postInstall
        # override would be silently ignored.
        installPhase = old.installPhase + ''
          rm -f \
            "$out/Applications/Raycast.app/Contents/Library/LaunchAgents/Updater.plist" \
            "$out/Applications/Raycast.app/Contents/Library/LaunchDaemons/Updater-Daemon.plist"
        '';
      }))
    ]);

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
