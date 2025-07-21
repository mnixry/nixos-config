{
  pkgs,
  inputs,
  extraLibs,
  ...
}:
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ] ++ extraLibs.scanPaths ./.;

  home.pointerCursor = {
    gtk.enable = true;
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
  };

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop"; # breezedark, breezetwilight
      cursor = {
        theme = "Vimix-cursors";
        size = 24;
      };
      iconTheme = "Papirus-Dark";
    };

    powerdevil = {
      AC = {
        whenSleepingEnter = "hybridSleep";
        powerProfile = "performance";
        autoSuspend.action = "nothing";
      };
      battery = {
        whenSleepingEnter = "standbyThenHibernate";
        powerProfile = "powerSaving";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
      };
    };

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
    };
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
    ];
  };
}
