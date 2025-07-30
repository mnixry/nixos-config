{
  config,
  pkgs,
  lib,
  ...
}:
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
      # Don't download files if they're already in the download directory
      auto-save-interval = 10;
      conditional-get = true;
      file-allocation = "falloc"; # Assume ext4, this is faster there
      optimize-concurrent-downloads = true;
      disk-cache = "64M"; # In-memory cache to avoid fragmentation
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
      bt-detach-seed-only = true; # Don't block downloads when seeding
      enable-dht = true;
      enable-dht6 = true;
      seed-ratio = 2;
      seed-time = 60;
    };
  };

  systemd.user.services.aria2 = {
    Unit.Description = "aria2 download manager";
    Service =
      let
        coreBin = name: lib.getExe' pkgs.coreutils name;
        inherit (config.xdg) configHome dataHome;
        sessionFile = "${dataHome}/aria2/session";
      in
      {
        ExecStartPre =
          let
            prestart = pkgs.writeScript "aria2-prestart" ''
              #!${pkgs.runtimeShell}
              ${coreBin "mkdir"} -p ${dataHome}/aria2

              if [ ! -e "${sessionFile}" ]; then
                  ${coreBin "touch"} ${sessionFile}
              fi
            '';
          in
          "${prestart}";

        ExecStart = lib.concatStringsSep " " [
          "${lib.getExe config.programs.aria2.package}"
          "--enable-rpc"
          "--rpc-listen-port=16800"
          "--conf-path=${configHome}/aria2/aria2.conf"
          "--save-session=${sessionFile}"
          "--input-file=${sessionFile}"
        ];

        ExecReload = "${coreBin "kill"} -HUP $MAINPID";

        # We don't want to class an exit before downloads finish as a
        # failure if we stop aria2c, since the entire point of it is
        # that it will resume the downloads.
        SuccessExitStatus = "7";

        # We use falloc, so if we use this unit on any other fs it will
        # cause issues
        Slice = "session.slice";
        ProtectSystem = "full";
      };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
