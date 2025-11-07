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
    (cutter.withPlugins builtins.attrValues)

    # Container tools
    dive
    buildah
    hadolint

    # Android tools
    android-tools
    scrcpy

    # Database tools
    sqlite
    sqlitebrowser

    # Miscellaneous tools
    tokei
    graphviz
    ffmpeg
    caddy
    openssl
    qalculate-qt
  ];

  programs.awscli = {
    enable = true;
  };
}
