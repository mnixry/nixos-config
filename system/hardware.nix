{
  lib,
  config,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (inputs.nixos-hardware + "/common/pc/laptop")
    (inputs.nixos-hardware + "/common/pc/ssd")
    (inputs.nixos-hardware + "/common/gpu/nvidia/prime.nix")
    (inputs.nixos-hardware + "/common/cpu/intel/meteor-lake")
  ];

  services.xserver.videoDrivers = [
    "nvidia"
    "displaylink"
  ];
  nixpkgs.overlays = [
    (self: super: {
      displaylink = super.displaylink.overrideAttrs (_: {
        version = "6.2.0-30";
        src = super.fetchurl {
          name = "displaylink-62.zip";
          url = "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
          hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
        };
      });
    })
  ];
  nixpkgs.config.cudaSupport = true;

  hardware.intelgpu.driver = "xe";
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    primeBatterySaverSpecialisation = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  specialisation.intel-xe.configuration = {
    boot.kernelParams =
      let
        deviceId = "7d51";
      in
      [
        "i915.force_probe=!${deviceId}"
        "xe.force_probe=${deviceId}"
      ];
  };

  specialisation.battery-saver.configuration = {
    powerManagement.powertop.enable = true;
  };
  powerManagement.enable = true;

  services = {
    fwupd.enable = true;
    thermald.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  environment.etc."libinput/local-overrides.quirks".text = lib.mkForce ''
    [Lenovo ThinkBook 16 G7+ IAH touchpad]
    MatchName=*GXTP5100*
    MatchDMIModalias=dmi:*svnLENOVO:*pvrThinkBook16G7+IAH*:*
    MatchUdevType=touchpad
    ModelPressurePad=1
  '';

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [
    "kvm-intel"
    "xe"
    "hid-logitech-dj"
    "hid-logitech-hidpp"
  ];
}
