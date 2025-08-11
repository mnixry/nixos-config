{
  pkgs,
  mkNixPak,
  nixpakModules,
  makeDesktopItem,
  ...
}:
let
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [
          ./nixpaks-common.nix
          nixpakModules.gui-base
          nixpakModules.network
        ];
        app.package = pkgs.telegram-desktop;
        flatpak = {
          appId = "org.telegram.desktop";
        };
        dbus = {
          enable = true;
          args = [ "--log" ];
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
  exePath = pkgs.lib.getExe wrapped.config.script;
in
pkgs.buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = "telegram";
      desktopName = "Telegram";
      comment = "New era of messaging";
      tryExec = "${exePath}";
      exec = "${exePath} -- %u";
      icon = "org.telegram.desktop";
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
    })
  ];
}
