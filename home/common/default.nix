{
  lib,
  pkgs,
  inputs,
  vars,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  home.username = "${vars.user.name}";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${vars.user.name}"
    else "/home/${vars.user.name}";

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

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
    ++ [
      inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  home.stateVersion = "25.11";
}
