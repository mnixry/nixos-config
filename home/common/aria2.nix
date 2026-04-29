{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (config.xdg) configHome dataHome;
  sessionFile = "${dataHome}/aria2/session";

  prestartScript = pkgs.writeScript "aria2-prestart" ''
    #!${pkgs.runtimeShell}
    ${lib.getExe' pkgs.coreutils "mkdir"} -p ${dataHome}/aria2

    if [ ! -e "${sessionFile}" ]; then
        ${lib.getExe' pkgs.coreutils "touch"} ${sessionFile}
    fi
  '';

  aria2Args = [
    "${lib.getExe config.programs.aria2.package}"
    "--enable-rpc"
    "--rpc-listen-port=16800"
    "--conf-path=${configHome}/aria2/aria2.conf"
    "--save-session=${sessionFile}"
    "--input-file=${sessionFile}"
  ];
in
{
  programs.aria2 = {
    enable = true;
    package = pkgs.aria2.overrideAttrs (_: {
      patches = [
        (pkgs.fetchpatch {
          name = "unlimited-max-connection.patch";
          url = "https://aur.archlinux.org/cgit/aur.git/plain/unlimited-max-connection.patch?h=aria2-unlimited&id=c1928d9c344f60eb431a0ba43c7bf73a31cf1253";
          hash = "sha256-x9sDiBXFNTixz4vpZ+NNZtdhQOMMycYHDa9PznUO7VM=";
        })
      ];
    });
    settings = {
      dir = config.xdg.userDirs.download;
      check-integrity = true;

      ## General optimization
      auto-save-interval = 10;
      conditional-get = true;
      file-allocation = if isLinux then "falloc" else "prealloc"; # falloc is ext4-optimized, prealloc for APFS
      optimize-concurrent-downloads = true;
      disk-cache = "64M";
      min-split-size = "1M";
      http-accept-gzip = true;
      content-disposition-default-utf8 = true;
      split = 64;
      max-concurrent-downloads = 10;
      max-connection-per-server = 64;
      max-download-limit = 0;
      max-overall-download-limit = 0;

      ## Torrent options
      bt-force-encryption = true;
      bt-detach-seed-only = true;
      enable-dht = true;
      enable-dht6 = true;
      seed-ratio = 2;
      seed-time = 60;
    };
  };

  # Linux: systemd user service
  systemd.user.services.aria2 = lib.mkIf isLinux {
    Unit.Description = "aria2 download manager";
    Service =
      let
        coreBin = name: lib.getExe' pkgs.coreutils name;
      in
      {
        ExecStartPre = "${prestartScript}";
        ExecStart = lib.concatStringsSep " " aria2Args;
        ExecReload = "${coreBin "kill"} -HUP $MAINPID";
        SuccessExitStatus = "7";
        Slice = "session.slice";
        ProtectSystem = "full";
      };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  # macOS: launchd user agent
  launchd.agents.aria2 = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.runtimeShell}"
        "-c"
        "${prestartScript} && exec ${lib.concatStringsSep " " aria2Args}"
      ];
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };
}
