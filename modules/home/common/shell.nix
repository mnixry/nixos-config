{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  home.shell.enableFishIntegration = true;

  programs.fish = {
    enable = true;
    generateCompletions = true;
    interactiveShellInit = ''
      # Disable the greeting message.
      set fish_greeting
    '';
  };

  programs.bash = {
    enable = true;
    enableVteIntegration = true;
    initExtra = lib.mkBefore ''
      source ${pkgs.blesh}/share/blesh/ble.sh
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableTransience = true;
    # custom settings
    settings =
      (fromTOML (builtins.readFile "${pkgs.starship}/share/starship/presets/nerd-font-symbols.toml"))
      // {
        shell.disabled = false;
      };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    mise.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    daemon.enable = true;
    settings = {
      sync_frequency = 0;
      inline_height = 10;
      history_filter = [
        ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])[^']*'|(\.|[^/\s-])[^\s]*))*\s*$)'' # filter ls command with non-absolute pathes
        ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$'' # filter cd command with non-absolute pathes
        "/nix/store/.*" # command contains /nix/store
        ''--cookie[=\s]+.+'' # command contains cookie
        ''^\s+'' # filter commands with leading spaces
      ];
      store_failed = false;
    };
  };

  programs.tealdeer.enable = true;
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.ghostty =
    let
      shaders = pkgs.fetchFromGitHub {
        owner = "sahaj-b";
        repo = "ghostty-cursor-shaders";
        rev = "06d4e90fb5410e9c4d0b3131584060adddf89406";
        hash = "sha256-G/UIr1bKnxn1AcHl/4FL/jou6b7M2VeREslYVELxdmw=";
      };
    in
    {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        command = "${pkgs.fish}/bin/fish --login --interactive";
        font-family = config.fonts.fontconfig.defaultFonts.monospace;
        keybind = [
          "global:cmd+backquote=toggle_quick_terminal"
        ];
        custom-shader = [
          "${shaders}/cursor_warp.glsl"
          "${shaders}/ripple_rectangle_cursor.glsl"
        ];

        background-opacity = 0.95;
        background-blur = true;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        quick-terminal-position = "top";
        quick-terminal-size = "40%";
        quick-terminal-screen = "main";
        quick-terminal-animation-duration = "0.15";
        quick-terminal-autohide = true;
        quick-terminal-space-behavior = "move";

        macos-option-as-alt = true;
      };
    };
}
