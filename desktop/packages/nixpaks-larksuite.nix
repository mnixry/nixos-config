{
  lib,
  coreutils,
  feishu,
  fetchurl,
  buildEnv,
  mkNixPak,
  nixpakModules,
  makeDesktopItem,
}:
let
  larksuite = feishu.overrideAttrs (prev: {
    pname = "lark";
    version = "7.46.11";
    src = fetchurl {
      url = "https://sf16-sg.larksuitecdn.com/obj/lark-artifact-storage/34c30532/Lark-linux_x64-7.46.11.deb";
      hash = "sha256-zaVptVQxCHO/8zMX93nXtxtq4g6QNtzQLOIK8ds0XXs=";
    };
    installPhase = (lib.replaceString "feishu" "lark" prev.installPhase) + ''
      wrapProgram $out/opt/bytedance/lark/bytedance-lark \
        --prefix PATH : ${lib.makeBinPath [ coreutils ]} \
        --add-flags "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true"
    '';
    meta.mainProgram = "bytedance-lark";
  });
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [
          ./nixpaks-common.nix
          nixpakModules.gui-base
          nixpakModules.network
        ];
        app.package = larksuite;
        flatpak = {
          appId = "com.larksuite.suite";
        };
        dbus = {
          enable = true;
          policies = {
            "org.freedesktop.secrets" = "talk";
            "org.gnome.keyring" = "talk";
            "org.gnome.ScreenSaver" = "talk";
          };
        };
        bubblewrap = {
          bind.rw = [ sloth.xdgDownloadDir ];
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
      name = "bytedance-lark";
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
    })
  ];
}
