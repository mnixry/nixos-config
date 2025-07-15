{ inputs, pkgs, ... }:
{
  imports = [ inputs.chaotic.nixosModules.default ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto.cachyOverride { mArch = "NATIVE"; };
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
}
