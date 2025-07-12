{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  preservation.enable = true;
  # pverservation required initrd using systemd.
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    # `sudo ncdu -x /`
    pkgs.ncdu
  ];

  # There are two ways to clear the root filesystem on every boot:
  ##  1. use tmpfs for /
  ##  2. (btrfs/zfs only)take a blank snapshot of the root filesystem and revert to it on every boot via:
  ##     boot.initrd.postDeviceCommands = ''
  ##       mkdir -p /run/mymount
  ##       mount -o subvol=/ /dev/disk/by-uuid/UUID /run/mymount
  ##       btrfs subvolume delete /run/mymount
  ##       btrfs subvolume snapshot / /run/mymount
  ##     '';
  #
  #  See also https://grahamc.com/blog/erase-your-darlings/

  # NOTE: preservation only mounts the directory/file list below to /persistent
  # If the directory/file already exists in the root filesystem you should
  # move those files/directories to /persistent first!
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/nixos"

      # my secrets
      "/etc/agenix/"

      "/var/log"

      # system-core
      "/var/lib/nixos"
      "/var/lib/systemd"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
      "/var/lib/sbctl" # lanzaboote - secure boot
      # containers
      # "/var/lib/docker"
      "/var/lib/cni"
      "/var/lib/containers"

      # other data
      "/var/lib/flatpak"

      # virtualisation
      "/var/lib/libvirt"
      "/var/lib/lxc"
      "/var/lib/lxd"
      "/var/lib/qemu"
      # "/var/lib/waydroid"

      # network
      "/var/lib/tailscale"
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
    ];
    files = [
      # auto-generated machine ID
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
      {
        file = "/etc/dae/config.dae";
        mode = "0600";
      }
    ];
  };

  # systemd-machine-id-commit.service would fail but it is not relevant
  # in this specific setup for a persistent machine-id so we disable it
  #
  # see the firstboot example below for an alternative approach
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # let the service commit the transient ID to the persistent volume
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };
}
