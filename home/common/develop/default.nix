{
  pkgs,
  lib,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  home.packages =
    with pkgs;
    [
      # Nix development tools
      nixd
      nixfmt
      nixfmt-tree

      # Git tools
      git-filter-repo
      git-graph

      # Container & Cloud Native tools
      dive
      skopeo
      hadolint
      yamlfmt
      kubectl
      kubernetes-helm
      kubeseal

      # Database tools
      duckdb
      sqlite

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
      just
      # CTF & RE tools
      gtkwave
      binwalk
      hashcat
      imhex
      wireshark

      # GUI/system tools
      android-tools
      scrcpy
      sqlitebrowser
      qalculate-qt
      freelens-bin
    ]
    # Linux-only tools (kernel/FHS/platform dependencies)
    ++ lib.optionals pkgs.stdenv.isLinux [
      # https://github.com/NixOS/nixpkgs/issues/514250
      (cutter.withPlugins builtins.attrValues)
      ida-pro
      ida-pro-mcp
      (burpsuite.override { inherit (jetbrains) jdk; })
      (detect-it-easy.overrideAttrs (
        { postInstall, ... }:
        {
          postInstall = postInstall + ''
            substituteInPlace $out/share/applications/io.github.horsicq.detect-it-easy.desktop \
              --replace "MimeType=application/octet-stream;" ""
          '';
        }
      ))
      hashcash
      bpftrace
      buildah
      perf
    ];

  programs.awscli = {
    enable = true;
  };
}
