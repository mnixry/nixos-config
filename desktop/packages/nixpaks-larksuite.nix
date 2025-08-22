{
  lib,
  feishu,
  fetchurl,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
}:
let
  appId = "com.larksuite.suite";
  larksuite = feishu.overrideAttrs (prev: {
    pname = "lark";
    version = "7.46.11";
    src = fetchurl {
      url = "https://sf16-sg.larksuitecdn.com/obj/lark-artifact-storage/34c30532/Lark-linux_x64-7.46.11.deb";
      hash = "sha256-zaVptVQxCHO/8zMX93nXtxtq4g6QNtzQLOIK8ds0XXs=";
    };
    installPhase = lib.replaceString "feishu" "lark" prev.installPhase;
    meta.mainProgram = "bytedance-lark";
  });
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = mkAppWrapper larksuite {
          binPath = "opt/bytedance/lark/lark";
          extraWrapperArgs = [
            "--add-flags"
            "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3"
          ];
        };
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.secrets" = "talk";
            "org.gnome.keyring" = "talk";
            "org.gnome.ScreenSaver" = "talk";
            "org.freedesktop.StatusNotifierItem.*" = "talk";
            "org.freedesktop.Notifications" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
            "com.canonical.AppMenu.Registrar" = "talk";
            "com.canonical.indicator.application" = "talk";
            "org.ayatana.indicator.application" = "talk";
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
      desktopName = "Lark";
      genericName = "Lark";
      comment = "Lark is a next-generation office suite that integrates messaging, schedule management, collaborative documents, video meeting, and various apps in one platform.";
      exec = "${exePath} %U";
      startupNotify = true;
      terminal = false;
      icon = "${larksuite}/share/icons/hicolor/256x256/apps/bytedance-lark.png";
      type = "Application";
      categories = [ "Office" ];
      mimeTypes = [
        "message/rfc822"
        "x-scheme-handler/feishu"
        "x-scheme-handler/feishu-open"
        "x-scheme-handler/lark"
        "x-scheme-handler/x-lark"
      ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
