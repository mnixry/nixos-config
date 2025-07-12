{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:

let
  luksName = "system";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (inputs.nixos-hardware + "/common/pc/laptop")
    (inputs.nixos-hardware + "/common/pc/ssd")
    (inputs.nixos-hardware + "/common/gpu/nvidia/prime.nix")
    (inputs.nixos-hardware + "/common/cpu/intel/meteor-lake")
  ];

  #   hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.intelgpu.driver = "xe";
  hardware.nvidia = {
    open = true;
    nvidiaSettings = lib.mkDefault true;
    modesetting.enable = lib.mkDefault true;
    primeBatterySaverSpecialisation = true;
    prime = {
      offload.enable = lib.mkDefault true;
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:1:0:0";
    };
  };

  powerManagement.enable = true;
  #   powerManagement.powertop.enable = true;

  services = {
    fwupd.enable = true;
    thermald.enable = true;
  };

  boot = {
    initrd = {
      systemd.enable = true;
      luks.fido2Support = false;
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
      luks.devices."${luksName}" = {
        device = "/dev/disk/by-uuid/febcf993-9a92-4ed9-8bb2-8df8bc810af6";
        crypttabExtraOpts = [ "fido2-device=auto" ];
        # whether to allow TRIM requests to the underlying device.
        # it's less secure, but faster.
        allowDiscards = true;
        # Whether to bypass dm-crypt’s internal read and write workqueues.
        # Enabling this should improve performance on SSDs;
        # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
        bypassWorkqueues = true;
      };
    };
    kernelModules = [
      "kvm-intel"
      "xe"
    ];
    extraModulePackages = [ ];
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    tmp.cleanOnBoot = true;
  };

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
        "compress-force=zstd:1"
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
    "/home" = {
      device = "/dev/mapper/${luksName}";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=@home"
        "compress=zstd"
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
      device = "/dev/disk/by-partuuid/c52e2372-9927-46e2-b626-d1b658ab622a";
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
  services.beesd.filesystems = {
    "${luksName}" = {
      spec = "/dev/mapper/${luksName}";
      extraOptions = [ "--loadavg-target=5.0" ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
