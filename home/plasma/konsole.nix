{ pkgs, config, ... }:
let
  defaultProfileName = "Normal";
in
{
  home.packages = with pkgs; [ kdePackages.yakuake ];

  programs.konsole = {
    enable = true;
    defaultProfile = defaultProfileName;
    profiles."${defaultProfileName}" = {
      name = defaultProfileName;
      colorScheme = "MateriaDark";
      extraConfig = {
        "Appearance"."UseFontLineChararacters" = true;
        "Terminal Features"."BellMode" = 2;
        "Scorlling"."HistoryMode" = 2;
      };
    };
  };

  programs.plasma.configFile = {
    yakuakerc = {
      "Dialogs"."FirstRun" = false;
      "Desktop Entry"."DefaultProfile" = "${defaultProfileName}.profile";
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
      "${config.home.profileDirectory}/share/applications/org.kde.yakuake.desktop"
    ];
  };
}
