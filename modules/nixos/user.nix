{ pkgs, host, ... }:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.fish.enable = true;
  programs.wireshark.enable = true;
  programs.traceroute.enable = true;
  users.users."${host.user.name}" = {
    isNormalUser = true;
    initialHashedPassword = host.user.initialHashedPassword;
    description = host.user.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
      "tss"
      "wireshark"
    ];
    shell = pkgs.fish;
  };

  security.pam.services."${host.user.name}".kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };
  services.dbus.packages = with pkgs; [ kdePackages.kwallet ];
}
