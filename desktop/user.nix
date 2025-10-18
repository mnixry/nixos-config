{
  pkgs,
  vars,
  ...
}:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.fish.enable = true;
  programs.wireshark.enable = true;
  users.users."${vars.user.name}" = {
    isNormalUser = true;
    initialHashedPassword = "${vars.user.initialHashedPassword}";
    description = "${vars.user.fullname}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "tss"
      "wireshark"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ bitwarden-desktop ];
  };

  security.pam.services."${vars.user.name}".kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };
  services.dbus.packages = with pkgs; [ kdePackages.kwallet ];
}
