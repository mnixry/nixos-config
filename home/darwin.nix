{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./common
  ];

  # Darwin-specific packages
  home.packages =
    (with pkgs; [
      # macOS softwares
      ice-bar
      alt-tab-macos
      qq
    ])
    ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      opencode
      oh-my-opencode
      (codex.overrideAttrs (prev: {
        nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.rustPlatform.bindgenHook ];
      }))
    ]);

  services.colima = {
    enable = true;
    profiles.default = {
      isService = true;
      isActive = true;
      settings = {
        runtime = "docker";
        arch = "host";

        vmType = "vz";
        mountType = "virtiofs";

        cpu = 4;
        memory = 4096;
        disk = 100;

        kubernetes.enabled = false;
        portForwarder = "ssh";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      command = "${pkgs.fish}/bin/fish --login --interactive";
      keybind = [
        "global:cmd+backquote=toggle_quick_terminal"
      ];

      quick-terminal-position = "top";
      quick-terminal-size = "40%";
      quick-terminal-screen = "main";
      quick-terminal-animation-duration = "0.15";
      quick-terminal-autohide = true;
      quick-terminal-space-behavior = "move";
    };
  };

  # Disable NixOS-specific settings
  xdg.mimeApps.enable = lib.mkForce false;

  # Disable dconf settings (virt-manager specific, not applicable on Darwin)
  dconf.settings = lib.mkForce { };

  # Use pinentry-mac instead of pinentry-qt on Darwin
  services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;

  # Remove NIXOS_OZONE_WL session variable (not applicable on Darwin)
  home.sessionVariables = lib.mkForce {
    # Darwin-specific session variables can go here
  };
}
