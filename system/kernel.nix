{ inputs, pkgs, ... }:
let
  linuxPackages = pkgs.linuxPackages_cachyos.override (super: {
    stdenv = pkgs.impureUseNativeOptimizations super.stdenv;
  });
  kernelPackages = (linuxPackages.cachyOverride { mArch = "NATIVE"; }).extend (
    lpself: lpsuper: {
      inherit (pkgs.linuxPackages_cachyos-gcc) evdi;
    }
  );
in
{
  imports = [ inputs.chaotic.nixosModules.default ];

  boot.kernelPackages = kernelPackages;
  boot.kernel.sysctl =
    let
      MB = 1024 * 1024;
      mkKB = x: toString (x * 1024);
      mkMB = x: toString (x * MB);
    in
    {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.rmem_max" = 64 * MB;
      "net.core.wmem_max" = 64 * MB;
      "net.ipv4.tcp_rmem" = "${mkKB 8} ${mkKB 256} ${mkMB 32}";
      "net.ipv4.tcp_wmem" = "${mkKB 4} ${mkKB 128} ${mkMB 32}";
      "net.ipv4.tcp_adv_win_scale" = "-2";
    };
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = [
      "--long"
      "--ultra"
      "-22"
      "-T0"
    ];
  };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
}
