{ pkgs, extraLibs, ... }:
{
  imports = extraLibs.scanPaths ./.;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # builtin families
      ubuntu-classic
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
          "JetBrainsMono Nerd Font"
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

  services.nixseparatedebuginfod2.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      icu
    ];
  };

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };
}
