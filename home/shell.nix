{ lib, pkgs, ... }:
{
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
}
