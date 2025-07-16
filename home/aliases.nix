{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    bat
    xcp
    eza
    libqalculate
    gtrash
    inxi
  ];

  home.shellAliases = {
    # shell
    cat = "${lib.getExe pkgs.bat} -p";
    cp = "${lib.getExe pkgs.xcp}";
    la = "${lib.getExe pkgs.eza} -lah --icons --git --group --modified";
    rm = "${lib.getExe pkgs.gtrash} put";
    rm-empty = "${lib.getExe pkgs.gtrash} find --rm";
    rm-restore = "${lib.getExe pkgs.gtrash} restore";
    bc = "${lib.getExe pkgs.libqalculate}";
    inxi = "${lib.getExe pkgs.inxi} -Fz";
    beep = ''echo -en "\007"'';
    journalctl-1h = ''journalctl -p err..alert --since "60 min ago"'';

    # network
    ip = "ip --color=auto";
    ip-info = "curl ip.im/info";

    # web
    paste-termbin = "nc termbin.com 9999";
    paste-rs = "curl --data-binary @- https://paste.rs/";

    # nix
    nix-build-package = ''nix build --impure --expr "(import <nixpkgs> {}).callPackage ./package.nix {}" -L'';
  };
}
