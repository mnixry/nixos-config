{
  config,
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
      docker-client
      docker-compose

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

  programs.docker-cli = {
    enable = true;
    configDir = "${config.xdg.configHome}/docker";
  };

  services.colima = {
    enable = true;
    profiles.default = {
      isService = true;
      isActive = true;
      setDockerHost = true;
      settings = {
        runtime = "docker";
        arch = "host";

        vmType = "vz";
        mountType = "virtiofs";

        cpu = 4;
        memory = 4;
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
}
