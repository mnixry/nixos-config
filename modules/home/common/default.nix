{
  pkgs,
  inputs,
  host,
  extraLibs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  username = host.user.name;

  addPlatformCompat =
    stdenv:
    stdenv
    // {
      inherit (stdenv.hostPlatform) isDarwin isLinux;
      override = args: addPlatformCompat (stdenv.override args);
    };

  # Bypass deprecated platform checks in pwndbg's flake-level package wiring.
  # Its package stack still expects these compatibility values in callPackage.
  pwndbg = import "${inputs.pwndbg}/nix/pwndbg.nix" {
    pkgs = pkgs.extend (
      _: prev: {
        stdenv = addPlatformCompat prev.stdenv;
      }
    );
    inputs = inputs.pwndbg.inputs // {
      self = inputs.pwndbg;
    };
    groups = [ "gdb" ];
  };
in
{
  imports = extraLibs.scanPaths ./.;

  home.username = "${username}";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  programs.man.generateCaches = pkgs.stdenv.hostPlatform.isLinux;

  # Packages shared across all platforms
  home.packages =
    (with pkgs; [
      fastfetch
      nnn

      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep
      jq
      yq-go
      eza
      fzf

      # networking tools
      mtr
      iperf3
      dnsutils
      ldns
      socat
      nmap
      ipcalc
      gdb
      nali

      # misc
      cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg

      # nix related
      nix-output-monitor
      nix-tree
      nix-update
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena

      # productivity
      hugo
      glow
      cloudflared

      # system tools
      lsof
    ])
    ++ (with inputs.llm-agents.packages.${system}; [
      kimi-code
      opencode
      codex
      omp
    ])
    ++ [
      pwndbg
      inputs.niks3.packages.${system}.default
    ];

  home.stateVersion = host.homeStateVersion;
}
