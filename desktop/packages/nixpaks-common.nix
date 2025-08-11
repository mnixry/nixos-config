{
  lib,
  sloth,
  ...
}:
{
  fonts.enable = lib.mkForce false;
  gpu = {
    enable = true;
    provider = lib.mkForce "nixos";
  };
  dbus.policies = {
    "org.freedesktop.appearance" = "talk";
    "org.freedesktop.appearance.*" = "talk";
  };
  bubblewrap = {
    tmpfs = [ "/tmp" ];
    bind.ro = [
      "/etc/fonts"
      (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
    ];
    bind.rw = with sloth; [
      [
        (mkdir appDataDir)
        xdgDataHome
      ]
      [
        (mkdir appConfigDir)
        xdgConfigHome
      ]
    ];
  };
}
