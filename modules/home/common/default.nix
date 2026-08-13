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
in
{
  imports = extraLibs.scanPaths ./.;

  home.username = "${username}";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  programs.man.generateCaches = pkgs.stdenv.isLinux;

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
      inputs.pwndbg.packages.${system}.default
      inputs.niks3.packages.${system}.default
    ];

  home.stateVersion = host.homeStateVersion;
}
