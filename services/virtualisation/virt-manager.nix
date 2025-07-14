{ pkgs, vars, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu
    qemu_kvm
  ];
  programs.virt-manager.enable = true;
  users.users."${vars.user.name}".extraGroups = [ "libvirtd" ];

  virtualisation.libvirtd = {
    enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
}
