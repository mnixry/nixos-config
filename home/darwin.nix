{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common
  ];

  # Darwin-specific packages
  home.packages = with pkgs; [
    # macOS softwares
    ice-bar
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

  # Disable dconf settings (virt-manager specific, not applicable on Darwin)
  dconf.settings = lib.mkForce { };

  # Use pinentry-mac instead of pinentry-qt on Darwin
  services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;

  # Remove NIXOS_OZONE_WL session variable (not applicable on Darwin)
  home.sessionVariables = lib.mkForce {
    # Darwin-specific session variables can go here
  };
}
