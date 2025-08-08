{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # builtin families
      ubuntu_font_family
      liberation_ttf
      # monospace families
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.monaspace
      sarasa-gothic
      # sans/serif families
      ibm-plex
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      noto-fonts
      # Persian Font
      vazir-fonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "IBM Plex Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        sansSerif = [
          "IBM Plex Sans"
          "IBM Plex Sans SC"
          "IBM Plex Sans TC"
          "IBM Plex Sans JP"
          "IBM Plex Sans KR"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Fonts"
          "Sarasa Term SC"
          "Sarasa Term TC"
          "Sarasa Term J"
          "Sarasa Term K"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
      };
    };
  };

  services.nixseparatedebuginfod.enable = true;
  programs.nix-ld.enable = true;
}
