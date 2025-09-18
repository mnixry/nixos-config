{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.go = {
    enable = true;
    telemetry.mode = "off";
    env =
      lib.attrsets.mapAttrs (name: value: lib.getExe' pkgs.gccgo value) {
        AR = "ar";
        CC = "gcc";
        CXX = "g++";
        GCCGO = "gccgo";
      }
      // rec {
        GOPATH = "${config.xdg.dataHome}/go";
        GOBIN = "${GOPATH}/bin";
      };
  };

  home = {
    packages = with pkgs; [
      gofumpt
      goimports-reviser
      golangci-lint
      golines
      gomodifytags
      gopls
      gotests
      go-tools # staticcheck
      gotools # goimports
      delve
      impl
      revive
    ];
    sessionPath = [ config.programs.go.env.GOBIN ];
  };
}
