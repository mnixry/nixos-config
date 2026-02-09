{
  lib,
  qq,
  libx11,
  libkrb5,
  stdenv,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
}:
let
  appId = "com.qq.QQ";
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = mkAppWrapper qq {
          binPath = "bin/qq";
          prefixLibraries = [
            libx11
            libkrb5
            stdenv.cc.cc
          ];
        };
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.Notifications" = "talk";
            "org.freedesktop.ScreenSaver" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
            "org.freedesktop.login1" = "talk";
          };
        };
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
          bind.rw = with sloth; [ xdgDownloadDir ];
        };
      };
  };
  exePath = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "QQ";
      genericName = "QQ";
      comment = "Tencent QQ, also known as QQ, is an instant messaging software service and web portal developed by the Chinese technology company Tencent.";
      exec = "${exePath} %U";
      startupNotify = true;
      terminal = false;
      icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
      type = "Application";
      categories = [
        "InstantMessaging"
        "Network"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
