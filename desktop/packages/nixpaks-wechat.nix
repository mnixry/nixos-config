{
  lib,
  wechat,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
}:
let
  appId = "com.tencent.WeChat";
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = mkAppWrapper wechat { };
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.FileManager1" = "talk";
            "org.freedesktop.Notifications" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
          };
        };
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
          bind.ro = [ "/etc/passwd" ];
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
      desktopName = "WeChat";
      genericName = "WeChat";
      comment = "WeChat, is a messaging and calling app developed by the Chinese technology company Tencent.";
      exec = "${exePath} %U";
      startupNotify = true;
      terminal = false;
      icon = "${wechat}/share/icons/hicolor/256x256/apps/wechat.png";
      type = "Application";
      categories = [
        "InstantMessaging"
        "Network"
      ];
      keywords = [
        "wechat"
        "weixin"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
