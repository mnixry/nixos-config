{ ... }:
{
  # Enable fontconfig so home-manager profile fonts are discoverable
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "IBM Plex Serif"
        "Noto Serif CJK SC"
        "Noto Serif CJK TC"
        "Noto Serif CJK JP"
        "Noto Serif CJK KR"
      ];
      sansSerif = [
        "IBM Plex Sans"
        "IBM Plex Sans SC"
        "IBM Plex Sans TC"
        "IBM Plex Sans JP"
        "IBM Plex Sans KR"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Sarasa Term SC"
        "Sarasa Term TC"
        "Sarasa Term J"
        "Sarasa Term K"
      ];
      emoji = [
        "Noto Color Emoji"
        "Noto Emoji"
      ];
    };
  };
}
