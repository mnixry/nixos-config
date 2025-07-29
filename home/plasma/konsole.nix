{ pkgs, ... }:
{
  home.packages = with pkgs; [ kdePackages.yakuake ];

  programs.konsole = {
    enable = true;
    defaultProfile = "normal";
    profiles.normal = {
      name = "normal";
      colorScheme = "MateriaDark";
      font = {
        name = "Monospace";
      };
      extraConfig = {
        "Appearance"."UseFontLineChararacters" = true;
        "Terminal Features"."BellMode" = 2;
        "Scorlling" = {
          "HistoryMode" = 1;
          "HistorySize" = 10 * 1000;
        };
      };
    };
  };

  programs.plasma.configFile = {
    yakuakerc = {
      "Dialogs"."FirstRun" = false;
      "Desktop Entry"."DefaultProfile" = "normal.profile";
      "Appearance"."Skin" = "materia-dark";
      "Window" = {
        "Height" = 72;
        "KeepOpen" = false;
      };
    };
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
    ];
  };
}
