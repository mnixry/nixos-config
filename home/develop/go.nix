{ config, pkgs, ... }:
{
  programs.go = {
    enable = true;
    telemetry.mode = "off";
    env = rec {
      goPath = "${config.xdg.dataHome}/go";
      goBin = "${goPath}/bin";
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
    sessionPath = [ config.programs.go.env.goBin ];
  };
}
