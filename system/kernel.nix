{ pkgs, inputs, ... }:
let
  kernelPackages =
    with pkgs;
    (linuxPackages_cachyos-lto.cachyOverride { mArch = "GENERIC_V3"; }).extend (
      lpself: lpsuper: {
        evdi = linuxPackages_cachyos-gcc.evdi.overrideAttrs (_: {
          version = "git";
          src = fetchFromGitHub {
            owner = "DisplayLink";
            repo = "evdi";
            rev = "e89796c565c5ae899b93a8f6323a52f089bb15c5";
            hash = "sha256-L2v7SMScQSRP9gzV4ihxJpRmW7eSvXhvORkTiZjSOu4=";
          };
        });
      }
    );
in
{
  imports = [ inputs.chaotic.nixosModules.default ];

  boot = {
    inherit kernelPackages;
    kernel.sysctl =
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
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "--long"
        "--ultra"
        "-22"
        "-T0"
      ];
    };
  };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
}
