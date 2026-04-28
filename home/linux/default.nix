{
  lib,
  pkgs,
  inputs,
  extraLibs,
  ...
}:
{
  imports = extraLibs.scanPaths ./.;

  xdg.mimeApps.enable = true;

  # Linux-only packages
  home.packages =
    (with pkgs; [
      xeyes
      lrzsz

      # system call monitoring
      strace
      ltrace

      # system tools
      sysstat
      lm_sensors
      ethtool
      pciutils
      usbutils
      numactl

      nixpaks.wpsoffice
      nixpaks.wemeet
      kdePackages.filelight
    ])
    ++ lib.filter (value: lib.isDerivation value) (builtins.attrValues pkgs.unixtools);

  services.remmina.enable = true;

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
