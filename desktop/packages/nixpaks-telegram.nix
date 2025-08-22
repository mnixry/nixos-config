{
  lib,
  telegram-desktop,
  buildEnv,
  mkNixPak,
  makeDesktopItem,
  ...
}:
let
  appId = "org.telegram.desktop";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = telegram-desktop;
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "org.gnome.Mutter.IdleMonitor" = "talk";
            "org.freedesktop.Notifications" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
            "com.canonical.AppMenu.Registrar" = "talk";
            "com.canonical.indicator.application" = "talk";
            "org.ayatana.indicator.application" = "talk";
            "org.sigxcpu.Feedback" = "talk";
          };
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
      desktopName = "Telegram";
      comment = "New era of messaging";
      tryExec = "${exePath}";
      exec = "${exePath} -- %u";
      icon = appId;
      terminal = false;
      type = "Application";
      categories = [
        "Chat"
        "Network"
        "InstantMessaging"
        "Qt"
      ];
      mimeTypes = [
        "x-scheme-handler/tg"
        "x-scheme-handler/tonsite"
      ];
      keywords = [
        "tg"
        "chat"
        "im"
        "messaging"
        "messenger"
        "sms"
        "tdesktop"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
