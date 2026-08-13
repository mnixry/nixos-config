{ pkgs, host, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu
    qemu_kvm
  ];
  programs.virt-manager.enable = true;
  users.users."${host.user.name}".extraGroups = [ "libvirtd" ];

  virtualisation.libvirtd = {
    enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
}
