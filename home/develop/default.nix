{
  pkgs,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    # Nix development tools
    nixd
    nixfmt
    nixfmt-tree

    # Git tools
    git-filter-repo
    git-graph

    # CTF tools
    gtkwave
    binwalk
    hashcat
    imhex
    wireshark
    bpftrace
    ida-pro
    ida-pro-mcp
    (cutter.withPlugins builtins.attrValues)
    (burpsuite.override { inherit (jetbrains) jdk; })
    (detect-it-easy.overrideAttrs (
      { postInstall, ... }:
      {
        postInstall = postInstall + ''
          substituteInPlace $out/share/applications/die.desktop \
            --replace "MimeType=application/octet-stream;" ""
        '';
      }
    ))

    # Container tools
    dive
    buildah
    hadolint
    kubectl
    kubeseal
    freelens-bin

    # Android tools
    android-tools
    scrcpy

    # Database tools
    duckdb
    sqlite
    sqlitebrowser

    # Miscellaneous tools
    tokei
    onefetch
    graphviz
    ffmpeg
    caddy
    openssl
    qalculate-qt
    just
  ];

  programs.awscli = {
    enable = true;
  };

  programs.ghidra = {
    enable = true;
    waylandSupport = true;
    # extensions = builtins.attrValues;
    preferences =
      let
        themeFile = pkgs.fetchurl {
          url = "https://github.com/zackelia/ghidra-dark-theme/raw/refs/heads/main/ghidra-dark.theme";
          hash = "sha256-ajjMtMpIAFxIHxMbAezISRv3u2ORO8sgcp7Rv2JKiKc=";
        };
      in
      {
        "GhidraShowWhatsNew" = false;
        "SHOW.HELP.NAVIGATION.AID" = true;
        "SHOW_TIPS" = true;
        "TIP_INDEX" = 0;
        "USER_AGREEMENT" = "ACCEPT";
        "Theme" = "File:${themeFile}";
      };
  };
}
