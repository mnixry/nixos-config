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
