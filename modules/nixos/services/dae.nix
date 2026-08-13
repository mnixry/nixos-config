{ inputs, pkgs, ... }:
{
  imports = [ inputs.daeuniverse.nixosModules.dae ];

  services.dae = {
    enable = true;
    openFirewall = {
      enable = true;
      port = 12345;
    };
    package = inputs.daeuniverse.packages."${pkgs.stdenv.hostPlatform.system}".dae-unstable;
    assets = [
      (pkgs.stdenvNoCC.mkDerivation {
        pname = "v2ray-rules-dat";
        version = inputs.v2ray-rules-dat.lastModifiedDate;
        src = inputs.v2ray-rules-dat;
        buildPhase = ''
          mkdir -p $out/share/v2ray
          for file in $src/*.dat; do
            cp $file $out/share/v2ray/$(basename $file)
          done
        '';
      })
    ];
    configFile = "/etc/dae/config.dae";
  };
}
