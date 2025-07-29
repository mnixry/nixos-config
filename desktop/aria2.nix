{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      aria2 = prev.aria2.overrideAttrs (_: {
        patches = [
          (pkgs.fetchpatch {
            name = "unlimited-max-connection.patch";
            url = "https://aur.archlinux.org/cgit/aur.git/plain/unlimited-max-connection.patch?h=aria2-unlimited&id=c1928d9c344f60eb431a0ba43c7bf73a31cf1253";
            hash = "sha256-x9sDiBXFNTixz4vpZ+NNZtdhQOMMycYHDa9PznUO7VM=";
          })
        ];
      });
    })
  ];

  services.aria2 = {
    enable = true;
    rpcSecretFile = "/dev/random";
  };
}
