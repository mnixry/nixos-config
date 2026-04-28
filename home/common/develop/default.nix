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
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # CTF tools (Linux-only due to GUI/kernel dependencies)
      gtkwave
      binwalk
      hashcat
      imhex
      wireshark

      # Linux-only GUI/system tools
      freelens-bin
      android-tools
      scrcpy
      sqlitebrowser
      qalculate-qt

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
