# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs."linuxPackages_cachyos-lto";
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.tmp.useTmpfs = true;

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  #   specialisation = {
  #     nvidia.configuration = {
  #       # Nvidia Configuration
  #       services.xserver.videoDrivers = [
  #         "modesetting"
  #         "nvidia"
  #       ];
  #       hardware.graphics.enable = true;
  #       # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #       hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  #       # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  #       hardware.nvidia.modesetting.enable = true;
  #       hardware.nvidia.prime = {
  #         offload = {
  #           enable = true;
  #           enableOffloadCmd = true;
  #         };
  #         #         sync.enable = true;
  #         # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #         nvidiaBusId = "PCI:1:0:0";
  #         # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #         intelBusId = "PCI:0:2:0";
  #       };
  #     };
  #   };

  networking.hostName = "mix-laptop-21tl"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  zramSwap.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-fluent
        fcitx5-mellow-themes
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
            fcitx5-pinyin-moegirl
            fcitx5-pinyin-zhwiki
          ];
        })
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # builtin families
      ubuntu_font_family
      liberation_ttf
      # monospace families
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.monaspace
      sarasa-gothic
      # sans/serif families
      ibm-plex
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      noto-fonts
      # Persian Font
      vazir-fonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "IBM Plex Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        sansSerif = [
          "IBM Plex Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Fonts"
          "Sarasa Term SC"
          "Sarasa Term TC"
          "Sarasa Term J"
          "Sarasa Term K"
          "Noto Color Emoji"
          "Noto Emoji"
        ];
      };
    };
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.dae = {
    enable = true;
    openFirewall = {
      enable = true;
      port = 12345;
    };
    package = inputs.daeuniverse.packages."${pkgs.system}".dae-unstable;
    configFile = "/etc/dae/config.dae";
    /*
      default options
      package = inputs.daeuniverse.packages.x86_64-linux.dae;
      disableTxChecksumIpGeneric = false;
      configFile = "/etc/dae/config.dae";
      assets = with pkgs; [ v2ray-geoip v2ray-domain-list-community ];
    */
    # alternative of `assets`, a dir contains geo database.
    # assetsPath = "/etc/dae";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
  environment.etc."libinput/local-overrides.quirks".text = pkgs.lib.mkForce ''
    [Lenovo ThinkBook 16 G7+ IAH touchpad]
    MatchName=*GXTP5100*
    MatchDMIModalias=dmi:*svnLENOVO:*pvrThinkBook16G7+IAH*:*
    MatchUdevType=touchpad
    ModelPressurePad=1
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mix = {
    isNormalUser = true;
    description = "HexMix";
    extraGroups = [
      "networkmanager"
      "wheel"
      "tss"
    ];
    packages = with pkgs; [
      fastfetch
      kdePackages.kate
      kdePackages.yakuake
      htop
      nixd
      nixfmt-rfc-style
      ungoogled-chromium
      #  thunderbird
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.garnix.io"
      #       "https://mirrors.cernet.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables

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
    refind
    sbctl
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
  system.stateVersion = "25.05"; # Did you read the comment?
}
