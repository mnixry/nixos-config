{
  pkgs,
  host,
  ...
}:
{
  imports = [ ../common/nix.nix ];

  environment.variables.DEVELOPER_DIR = toString pkgs.command-line-tools;

  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
    };
  };

  nix.gc.interval = {
    Weekday = 0;
    Hour = 0;
    Minute = 0;
  };

  # User configuration
  networking.hostName = host.name;
  system.primaryUser = host.user.name;

  users.users."${host.user.name}" = {
    home = "/Users/${host.user.name}";
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
}
