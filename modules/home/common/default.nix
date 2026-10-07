{
  lib,
  pkgs,
  inputs,
  host,
  extraLibs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  username = host.user.name;

  addPlatformCompat =
    stdenv:
    stdenv
    // {
      inherit (stdenv.hostPlatform) isDarwin isLinux;
      override = args: addPlatformCompat (stdenv.override args);
    };

  # Bypass deprecated platform checks in pwndbg's flake-level package wiring.
  # Its package stack still expects these compatibility values in callPackage.
  pwndbg = import "${inputs.pwndbg}/nix/pwndbg.nix" {
    pkgs = pkgs.extend (
      _: prev: {
        stdenv = addPlatformCompat prev.stdenv;
      }
    );
    inputs = inputs.pwndbg.inputs // {
      self = inputs.pwndbg;
    };
    groups = [ "gdb" ];
  };

  claude-code = (
    let
      unsupportedCountries = "AF|BY|CN|CU|HK|IR|KP|MM|MO|RU|SY|VE|YE";
      geoCheck = pkgs.writeShellApplication {
        name = "geo-check";
        runtimeInputs = with pkgs; [
          curl
          gnused
        ];
        text = ''
          loc=$(curl -fsS --max-time 5 https://claude.ai/cdn-cgi/trace 2>/dev/null | sed -n 's/^loc=//p' || true)
          case "$loc" in ${unsupportedCountries})
              echo "Anthropic does not support your region ($loc)" >&2
              exit 1
              ;;
          esac
        '';
      };
    in
    inputs.llm-agents.packages.${system}.claude-code.overrideAttrs (
      { postFixup, ... }:
      let
        anchor = "--set DISABLE_INSTALLATION_CHECKS 1";
      in
      {
        postFixup =
          assert lib.assertMsg (lib.hasInfix anchor postFixup)
            "upstream postFixup changed, re-check the injection anchor";
          lib.replaceString anchor ''
            ${anchor} \
              --set DISABLE_TELEMETRY 1 \
              --set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1 \
              --set DO_NOT_TRACK 1 \
              --set DISABLE_GROWTHBOOK 1 \
              --set DISABLE_ERROR_REPORTING 1 \
              --run "${lib.getExe geoCheck} || exit 1" \
          '' postFixup;
      }
    )
  );
in
{
  imports = extraLibs.scanPaths ./.;

  home = { inherit username; };

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  programs.man.generateCaches = pkgs.stdenv.hostPlatform.isLinux;

  # Packages shared across all platforms
  home.packages =
    (with pkgs; [
      fastfetch
      nnn

      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep
      ast-grep
      jq
      yq-go
      eza
      fzf

      # networking tools
      mtr
      iperf3
      dnsutils
      ldns
      socat
      nmap
      ipcalc
      gdb
      nali

      # misc
      cowsay
      file
      which
      tree
      zstd
      gnupg

      # nix related
      nix-output-monitor
      nix-tree
      nix-update
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena

      # productivity
      hugo
      glow
      cloudflared

      # system tools
      lsof
    ])
    ++ (with inputs.llm-agents.packages.${system}; [
      kimi-code
      opencode
      codex
    ])
    ++ [
      pwndbg
      claude-code
      inputs.niks3.packages.${system}.default
    ];

  home.stateVersion = host.homeStateVersion;
}
