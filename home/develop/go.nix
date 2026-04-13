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
      lib.attrsets.mapAttrs (name: value: lib.getExe' pkgs.stdenv.cc value) {
        AR = "ar";
        CC = "gcc";
        CXX = "g++";
      }
      // rec {
        GOPATH = "${config.xdg.dataHome}/go";
        GOBIN = "${GOPATH}/bin";
      };
  };

  home = {
    packages =
      (with pkgs; [
        # https://github.com/NixOS/nixpkgs/issues/509480
        (lib.hiPrio gopls)
        gotools # goimports
      ])
      ++ (with pkgs; [
        gofumpt
        goimports-reviser
        golangci-lint
        golines
        gomodifytags
        gotests
        go-tools # staticcheck
        delve
        impl
        revive
      ]);
    sessionPath = [ config.programs.go.env.GOBIN ];
  };
}
