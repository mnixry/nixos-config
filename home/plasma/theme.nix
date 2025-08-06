{
  pkgs,
  config,
  ...
}:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.vimix-cursors;
    name = "Vimix-cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.materia-theme;
      name = "Materia-dark";
    };
    gtk3.extraCss =
      let
        cfg3 = config.gtk.gtk3;
      in
      ''
        @import url("file://${cfg3.theme.package}/share/themes/${cfg3.theme.name}/gtk-3.0/gtk.css");
      '';
  };

  programs.plasma = {
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop"; # breezedark, breezetwilight
      cursor = {
        theme = "Vimix-cursors";
        size = 24;
      };
      iconTheme = "Papirus-Dark";
    };
    configFile = {
      kdeglobals.General.ColorScheme = "MateriaDark";
      kdeglobals.KDE.widgetStyle = "kvantum-dark";
      plasmarc.Theme.name = "Materia-Color";
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kde6";
  };

  programs.kvantum = {
    enable = true;
    theme.package = pkgs.materia-kde-theme;
    theme.name = "MateriaDark";
    theme.overrides = {
      General = {
        no_inactiveness = true;
        translucent_windows = true;
        reduce_window_opacity = 13;
        reduce_menu_opacity = 13;
        drag_from_buttons = false;
        shadowless_popup = true;
        popup_blurring = true;
        menu_blur_radius = 5;
        tooltip_blur_radius = 5;
      };
      Hacks = {
        transparent_dolphin_view = true;
        style_vertical_toolbars = true;
      };
    };
  };
}
