{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

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

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableTransience = true;
    # custom settings
    settings =
      (builtins.fromTOML (
        builtins.readFile "${pkgs.starship}/share/starship/presets/nerd-font-symbols.toml"
      ))
      // {
        shell.disabled = false;
      };
  };

  programs.atuin = {
    enable = true;
    package = pkgs.atuin.overrideAttrs (_: {
      patches = [
        (pkgs.fetchpatch {
          name = "fix-fish-up-binding.patch";
          url = "https://github.com/atuinsh/atuin/commit/cc2b7170290d699f7021483df3fd9ca1afe8bc43.patch";
          hash = "sha256-V/mSaUxn6RJwwaPwoYeyxt2b8cj5f7pU5oUE88k76M8=";
        })
      ];
    });
    enableBashIntegration = true;
    enableFishIntegration = true;
    daemon.enable = true;
    settings = {
      sync_frequency = 0;
      inline_height = 10;
      history_filter = [
        ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])[^']*'|(\.|[^/\s-])[^\s]*))*\s*$)'' # filter ls command with non-absolute pathes
        ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$'' # filter cd command with non-absolute pathes
        ''/nix/store/.*'' # command contains /nix/store
        ''--cookie[=\s]+.+'' # command contains cookie
      ];
      store_failed = false;
    };
  };

  programs.tealdeer.enable = true;
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
