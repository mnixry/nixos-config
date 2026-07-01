{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common
  ];

  # Darwin-specific packages
  home.packages = (
    with pkgs;
    [
      docker-client
      docker-compose

      # macOS softwares
      xcbuild
      nano
      (ice-bar.overrideAttrs rec {
        version = "0.11.13-dev.2";
        src = fetchurl {
          url = "https://github.com/jordanbaird/Ice/releases/download/${version}/Ice.zip";
          hash = "sha256-wbuqcfYev+Xuko95CvYJY6nyAjZNY/eNLGs+xRBc9KA=";
        };
      })
      alt-tab-macos
      powertop-macos
      spotify
      raycast
    ]
  );

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

  programs.ghostty =
    let
      shaders = pkgs.fetchFromGitHub {
        owner = "sahaj-b";
        repo = "ghostty-cursor-shaders";
        rev = "06d4e90fb5410e9c4d0b3131584060adddf89406";
        hash = "sha256-G/UIr1bKnxn1AcHl/4FL/jou6b7M2VeREslYVELxdmw=";
      };
    in
    {
      enable = true;
      package = pkgs.ghostty-bin;
      settings = {
        command = "${pkgs.fish}/bin/fish --login --interactive";
        font-family = config.fonts.fontconfig.defaultFonts.monospace;
        keybind = [
          "global:cmd+backquote=toggle_quick_terminal"
        ];
        custom-shader = [
          "${shaders}/cursor_warp.glsl"
          "${shaders}/ripple_rectangle_cursor.glsl"
        ];

        background-opacity = 0.95;
        background-blur = true;

        quick-terminal-position = "top";
        quick-terminal-size = "40%";
        quick-terminal-screen = "main";
        quick-terminal-animation-duration = "0.15";
        quick-terminal-autohide = true;
        quick-terminal-space-behavior = "move";

        macos-option-as-alt = true;
      };
    };
}
