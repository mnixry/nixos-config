{
  pkgs,
  lib,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  home.packages = with pkgs; [
    # C/C++ development tools
    (lib.hiPrio gcc_multi)
    (lib.hiPrio clang-tools)
    clang_multi
    libllvm
    bear
    patchelf
    man-pages
    man-pages-posix

    # Nix development tools
    nixd
    nixfmt-rfc-style
    nixfmt-tree

    # Git tools
    git-filter-repo
    git-graph

    # CTF tools
    hashcat
    imhex
    wireshark
    bpftrace
    ida-pro
    ida-pro-mcp
    (cutter.withPlugins builtins.attrValues)
    detect-it-easy

    # Container tools
    dive
    buildah
    hadolint

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
