{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  extraLibs,
  ...
}:
{
  imports = [
    ../home/shell.nix
    ../home/security.nix
    ../home/aliases.nix
    ../home/browsers.nix
    ../home/aria2.nix
    ../home/top.nix
    ../home/develop
    ../home/modules
  ];

  home.username = "${vars.user.name}";
  home.homeDirectory = "/Users/${vars.user.name}";

  # Darwin-specific packages
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
      nh
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

      # macOS softwares
      ice-bar
    ])
    ++ [
      inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      command = "${pkgs.fish}/bin/fish --login --interactive";
    };
  };

  # Disable NixOS-specific settings
  xdg.mimeApps.enable = lib.mkForce false;

  # Disable dconf settings (virt-manager specific)
  dconf.settings = lib.mkForce { };

  # Use pinentry-mac instead of pinentry-qt on Darwin
  services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;

  # Remove NIXOS_OZONE_WL session variable (not applicable on Darwin)
  home.sessionVariables = lib.mkForce {
    # Darwin-specific session variables can go here
  };

  home.stateVersion = "25.11";
}
