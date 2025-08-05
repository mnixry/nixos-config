{
  pkgs,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.niri.nixosModules.niri ];

  chaotic.mesa-git.enable = true;
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  specialisation.niri.configuration = {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.fish.enable = true;

  users.users."${vars.user.name}" = {
    isNormalUser = true;
    initialHashedPassword = "${vars.user.initialHashedPassword}";
    description = "${vars.user.fullname}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "tss"
    ];
    shell = pkgs.fish;
  };

  security.pam.services."${vars.user.name}".kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };
}
