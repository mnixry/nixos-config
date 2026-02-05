{ pkgs, lib, ... }:
let
  linuxKernel = pkgs.linuxKernel.kernels.linux_xanmod_latest;
  mkLTOKernel =
    kernel:
    kernel.override (prev: {
      inherit (pkgs.pkgsLLVM) stdenv;
      buildLinux =
        attrs:
        prev.buildLinux (
          lib.recursiveUpdate attrs {
            structuredExtraConfig = with lib.kernel; {
              GENERIC_CPU = yes;
              X86_64_VERSION = freeform "3";
              LTO_CLANG_THIN = yes;
              # these options are not supported by kernel with LLVM LTO
              DRM_PANIC_SCREEN_QR_CODE = lib.mkForce unset;
              RUST = lib.mkForce unset;
              RUST_FW_LOADER_ABSTRACTIONS = lib.mkForce unset;
              DRM_NOVA = lib.mkForce unset;
              NOVA_CORE = lib.mkForce unset;
            };
          }
        );
    });
  kernelPackages = (pkgs.linuxPackagesFor (mkLTOKernel linuxKernel)).extend (
    lpself: lpsuper: {
      inherit (pkgs.linuxPackagesFor linuxKernel) evdi nvidiaPackages;
    }
  );
in
{
  boot = {
    inherit kernelPackages;
    extraModulePackages = with kernelPackages; [ v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
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
