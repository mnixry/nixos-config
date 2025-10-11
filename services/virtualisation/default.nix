{ ... }:
{
  imports = [
    ./docker.nix
    ./virt-manager.nix
  ];

  boot.binfmt = {
    preferStaticEmulators = true;
    emulatedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"

      "loongarch64-linux"

      "mips-linux"
      "mipsel-linux"
      "mips64-linux"
      "mips64-linuxabin32"
      "mips64el-linux"
      "mips64el-linuxabin32"

      "riscv32-linux"
      "riscv64-linux"

      "wasm32-wasi"
      "wasm64-wasi"
    ];
  };
}
