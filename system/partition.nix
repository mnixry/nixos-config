{ vars, ... }:
let
  inherit (vars.hardware) luksName;
in
{
  boot.tmp.cleanOnBoot = true;
  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      # set mode to 755, otherwise systemd will set it to 777, which cause problems.
      # relatime: Update inode access times relative to modify or change time.
      options = [
        "relatime"
        "mode=755"
      ];
    };
    "/.btr_pool" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      # btrfs's top-level subvolume, internally has an id 5
      # we can access all other subvolumes from this subvolume.
      options = [ "subvolid=5" ];
    };
    "/tmp" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=@tmp"
        "compress=zstd"
      ];
    };
    "/nix" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=@nix"
        "compress-force=zstd"
        "noatime"
      ];
    };
    "/swap" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=@swap"
        "noatime"
        "ro"
      ];
    };
    "/swap/swapfile" = {
      depends = [ "/swap" ]; # the swapfile is located in /swap subvolume, so we need to mount /swap first.
      device = "/swap/swapfile";
      fsType = "none";
      options = [
        "bind"
        "rw"
      ];
    };
    "/persistent" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      options = [
        "subvol=@persistent"
        "compress=zstd"
      ];
      # preservation's data is required for booting.
      neededForBoot = true;
    };
    "/boot" = {
      device = "${vars.hardware.bootDevice}";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/.btr_pool" ];
  };

  nixpkgs.overlays = [
    (final: super: {
      bees = super.bees.overrideAttrs (prev: {
        version = "git";
        src = super.fetchFromGitHub {
          owner = "Zygo";
          repo = "bees";
          rev = "master";
          hash = "sha256-2Kx9cQOCPWYJZOstGle4FothAx40qFOeUDlyKGmIQ9k=";
        };
      });
    })
  ];
  services.beesd.filesystems = {
    "${luksName}" = {
      spec = "/dev/mapper/${luksName}";
      verbosity = "debug";
    };
  };
}
