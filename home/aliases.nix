{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
  };
  programs.eza.enable = true;

  home.packages = with pkgs; [
    (lib.hiPrio uutils-coreutils-noprefix)
    (lib.hiPrio uutils-diffutils)
    (lib.hiPrio uutils-findutils)
    xcp
    libqalculate
    gtrash
    inxi
  ];

  home.shellAliases = {
    # shell
    cat = "bat -p";
    cp = "xcp";
    la = "eza -lah --icons --git --group --modified";
    rm = "gtrash put";
    rm-empty = "gtrash find --rm";
    rm-restore = "gtrash restore";
    bc = "libqalculate";
    inxi = "inxi -Fz";
    beep = ''echo -en "\007"'';
    journalctl-1h = ''journalctl -p err..alert --since "60 min ago"'';
    man = "batman";

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
