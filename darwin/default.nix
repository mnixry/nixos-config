{
  config,
  pkgs,
  lib,
  vars,
  inputs,
  extraLibs,
  ...
}:
{
  # Nixpkgs configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
    };
  };

  # Nix configuration
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
    settings = {
      keep-going = true;
      always-allow-substitutes = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://nix-cache.any-mix.eu.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "nix-cache.any-mix.eu.org-1:1arBVKbTurqBX3Foe+tO8MihDz6qmVjNgnJ/lE3p1QI="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      narinfo-cache-negative-ttl = 60;
      auto-optimise-store = false;
      http-connections = 0;
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
  };

  # User configuration
  system.primaryUser = vars.user.name;

  users.users."${vars.user.name}" = {
    home = "/Users/${vars.user.name}";
    shell = pkgs.fish;
  };

  # Enable Fish shell
  programs.fish.enable = true;

  # Enable Zsh (macOS default login shell)
  programs.zsh.enable = true;

  # Register nix shells as valid login shells
  environment.shells = with pkgs; [
    fish
    zsh
  ];

  # Font packages (installed to /Library/Fonts/Nix Fonts)
  fonts.packages = with pkgs; [
    # builtin families
    ubuntu-classic
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

  # Basic system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  # macOS system defaults
  system.defaults = {
    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    # NSGlobalDomain settings
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
  };

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = false;
  };

  # Disable macOS developer tools prompt by ensuring Nix git shadows system stub
  environment.variables = {
    # Skip xcode-select developer tools prompt
    # Nix's git will be used instead of /usr/bin/git
  };

  # Ensure Nix binaries come before system stubs in PATH
  environment.systemPath = lib.mkBefore [
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
  ];

  # Homebrew integration (optional - uncomment if you use Homebrew)
  # homebrew = {
  #   enable = true;
  #   onActivation = {
  #     autoUpdate = true;
  #     cleanup = "zap";
  #   };
  #   casks = [
  #     # Add your Homebrew casks here
  #   ];
  # };

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;
}
