{
  lib,
  pkgs,
  vars,
  inputs,
  extraLibs,
  ...
}:
{
  imports = [ inputs.lix-module.nixosModules.default ] ++ extraLibs.scanPaths ./.;

  networking = {
    hostName = "${vars.network.hostname}";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-fortisslvpn
        networkmanager-iodine
        networkmanager-l2tp
        networkmanager-openconnect
        networkmanager-openvpn
        networkmanager-sstp
        networkmanager-strongswan
        networkmanager-vpnc
      ];
    };
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
  };

  nix = {
    channel.enable = false;
    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    optimise.automatic = true;
    settings = {
      keep-going = true;
      always-allow-substitutes = false;
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
      ];
      substituters = lib.mkAfter [
        "https://nix-cache.any-mix.eu.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "nix-cache.any-mix.eu.org-0:MjiS/nKakYJiXgA32BM3vBbdBZUZ0r5DeL6dhuJwPn0="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      narinfo-cache-negative-ttl = 60;
      use-cgroups = true;
      auto-allocate-uids = true;
      auto-optimise-store = false;
    };
    registry = {
      "short" = {
        from = {
          id = "p";
          type = "indirect";
        };
        to = {
          type = "path";
          path = inputs.self;
        };
      };
    };
    daemonCPUSchedPolicy = "batch";
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  zramSwap.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    fish
    pciutils
    usbutils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
