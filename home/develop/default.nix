{
  pkgs,
  lib,
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

    # Container & Cloud Native tools
    dive
    skopeo
    hadolint
    yamlfmt
    kubectl
    kubernetes-helm
    kubeseal
    freelens-bin

    # Android tools
    android-tools
    scrcpy

    # Database tools
    duckdb
    sqlite
    sqlitebrowser

    # Performance tools
    pprof
    gnuplot

    # Miscellaneous tools
    tokei
    onefetch
    graphviz
    ffmpeg
    caddy
    openssl
    qalculate-qt
    just
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    ida-pro
    ida-pro-mcp
    (cutter.withPlugins builtins.attrValues)
    (burpsuite.override { inherit (jetbrains) jdk; })
    hashcash
    (detect-it-easy.overrideAttrs (
      { postInstall, ... }:
      {
        postInstall = postInstall + ''
          substituteInPlace $out/share/applications/die.desktop \
            --replace "MimeType=application/octet-stream;" ""
        '';
      }
    ))
    bpftrace
    buildah
    perf
  ];

  programs.awscli = {
    enable = true;
  };
}
