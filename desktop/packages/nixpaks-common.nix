{
  lib,
  pkgs,
  sloth,
  config,
  ...
}:
{
  fonts.enable = lib.mkDefault false;
  locale.enable = lib.mkDefault true;

  gpu = {
    enable = true;
    provider = lib.mkForce "nixos";
  };

  dbus.policies = {
    "${config.flatpak.appId}" = "own";
    "${config.flatpak.appId}.*" = "own";
    "org.freedesktop.DBus" = "talk";
    "org.gtk.vfs.*" = "talk";
    "org.gtk.vfs" = "talk";
    "ca.desrt.dconf" = "talk";
    "org.freedesktop.portal.*" = "talk";
    "org.a11y.Bus" = "talk";
    "org.freedesktop.appearance" = "talk";
    "org.freedesktop.appearance.*" = "talk";
  };

  etc.sslCertificates.enable = true;
  bubblewrap = {
    network = lib.mkDefault true;
    sockets = {
      wayland = true;
      pulse = true;
    };

    bind.rw = with sloth; [
      [
        (mkdir appDataDir)
        xdgDataHome
      ]
      [
        (mkdir appConfigDir)
        xdgConfigHome
      ]
      [
        (mkdir appCacheDir)
        xdgCacheHome
      ]

      (sloth.concat [
        sloth.runtimeDir
        "/"
        (sloth.envOr "WAYLAND_DISPLAY" "no")
      ])
      (sloth.concat' sloth.runtimeDir "/at-spi/bus")
      (sloth.concat' sloth.runtimeDir "/gvfsd")
      (sloth.concat' sloth.runtimeDir "/dconf")

      (sloth.concat' sloth.xdgCacheHome "/fontconfig")
      (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
      (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache_db")
      (sloth.concat' sloth.xdgCacheHome "/radv_builtin_shaders")
    ];
    bind.ro = [
      (sloth.concat' sloth.runtimeDir "/doc")
      (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
      (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
      (sloth.concat' sloth.xdgConfigHome "/fontconfig")
      (sloth.concat' sloth.xdgConfigHome "/dconf")

      # Use system font settings instead
      "/etc/fonts"
      "/etc/localtime"

      # Fix: libEGL warning: egl: failed to create dri2 screen
      "/etc/egl"
      "/etc/static/egl"
    ];
    bind.dev = [ "/dev/shm" ] ++ (map (id: "/dev/video${toString id}") (lib.lists.range 0 9));
    tmpfs = [ "/tmp" ];
    env =
      let
        iconTheme = pkgs.papirus-icon-theme;
        cursorTheme = pkgs.vimix-cursors;
      in
      {
        XDG_DATA_DIRS = lib.mkForce (
          lib.makeSearchPath "share" [
            iconTheme
            cursorTheme
            pkgs.shared-mime-info
          ]
        );
        XCURSOR_PATH = lib.mkForce (
          lib.concatStringsSep ":" [
            "${cursorTheme}/share/icons"
            "${cursorTheme}/share/pixmaps"
          ]
        );
      };
  };
}
