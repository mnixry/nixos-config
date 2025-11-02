{
  lib,
  wemeet,
  fetchurl,
  buildEnv,
  mkAppWrapper,
  mkNixPak,
  makeDesktopItem,
}:
let
  appId = "com.tencent.wemeet";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [ ./nixpaks-common.nix ];
        app.package = mkAppWrapper (wemeet.overrideAttrs (_: {
          version = "3.26.10.400";
          src = fetchurl {
            url = "https://updatecdn.meeting.qq.com/cos/9cfd93b10ee81b2fc3ad26357f27ed13/TencentMeeting_0300000000_3.26.10.400_x86_64_default.publish.deb";
            hash = "sha256-7gN40mkAD/0/k0E+bBNfiMcY+YtIaLWycFoI+hhrjgc=";
          };
          postInstall = ''
            # cmp rdi, 0 -> cmp r12, 0, at co_jump_to_link to address coroutine context resume issue
            echo -ne '\x49\x83\xfc\x00' | dd of=$out/app/wemeet/lib/libwemeet_base.so bs=1 seek=$((0x94c833)) conv=notrunc
          '';
        })) { binPath = "bin/wemeet-xwayland"; };
        flatpak = { inherit appId; };
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
        };
        dbus.policies = {
          "org.gnome.Shell.Screencast" = "talk";
          "org.freedesktop.Notifications" = "talk";
          "org.kde.StatusNotifierWatcher" = "talk";
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
      desktopName = "WemeetApp";
      genericName = "Wemeet";
      comment = "A cloud-based HD conferencing product leveraging Tencent's 20+ years of experience in audiovisual communications";
      exec = "${exePath} %u";
      terminal = false;
      icon = "${wemeet}/share/icons/hicolor/scalable/apps/wemeet.svg";
      type = "Application";
      categories = [ "Office" ];
      keywords = [
        "wemeet"
        "tencent"
        "meeting"
      ];
      mimeTypes = [ "x-scheme-handler/wemeet" ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
