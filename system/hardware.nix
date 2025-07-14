{
  lib,

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
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
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
  ];
}
