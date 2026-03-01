{
  lib,
  pkgs,
  config,
  ...
}:
{
  xdg.mimeApps.defaultApplicationPackages = [ config.programs.mpv.package ];

  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    scripts = with pkgs.mpvScripts; [
      thumbfast
      modernz
      # https://github.com/NixOS/nixpkgs/pull/490264
      # mpv-cheatsheet-ng
      visualizer
    ];
    config = {
      osc = false;
      border = false;
      deband = true;
      icc-profile-auto = true;
      blend-subtitles = "video";
      cscale = "catmull_rom";
      video-sync = "display-resample";
      tscale = "oversample";
      sub-auto = "fuzzy";
      hwdec = "auto-safe";
      vo = "gpu";
    };
    bindings =
      let
        # Helper – builds a keybinding given:
        #  key:     "CTRL+1"
        #  label:   "Anime4K: Mode A (HQ)"
        #  shaders: list of shader filenames
        mkPreset = key: label: shaders: {
          ${key} = ''no-osd change-list glsl-shaders set "${
            builtins.concatStringsSep ":" (map (s: "~~/shaders/Anime4K/${s}") shaders)
          }"; show-text "${label}"'';
        };
        mkClearPreset = key: {
          ${key} = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
        };
      in
      # Merge all presets with // (attrset union)
      lib.attrsets.mergeAttrsList [
        (mkPreset "CTRL+1" "Anime4K: Mode A (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Restore_CNN_VL.glsl"
          "Anime4K_Upscale_CNN_x2_VL.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkPreset "CTRL+2" "Anime4K: Mode B (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Restore_CNN_Soft_VL.glsl"
          "Anime4K_Upscale_CNN_x2_VL.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkPreset "CTRL+3" "Anime4K: Mode C (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkPreset "CTRL+4" "Anime4K: Mode A+A (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Restore_CNN_VL.glsl"
          "Anime4K_Upscale_CNN_x2_VL.glsl"
          "Anime4K_Restore_CNN_M.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkPreset "CTRL+5" "Anime4K: Mode B+B (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Restore_CNN_Soft_VL.glsl"
          "Anime4K_Upscale_CNN_x2_VL.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Restore_CNN_Soft_M.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkPreset "CTRL+6" "Anime4K: Mode C+A (HQ)" [
          "Anime4K_Clamp_Highlights.glsl"
          "Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
          "Anime4K_AutoDownscalePre_x2.glsl"
          "Anime4K_AutoDownscalePre_x4.glsl"
          "Anime4K_Restore_CNN_M.glsl"
          "Anime4K_Upscale_CNN_x2_M.glsl"
        ])
        (mkClearPreset "CTRL+0")
      ];
  };

  xdg.configFile."mpv/shaders/Anime4K".source =
    let
      src = pkgs.fetchurl {
        url = "https://github.com/Tama47/Anime4K/releases/download/v4.0.1/GLSL_Mac_Linux_High-end.zip";
        sha256 = "sha256-6AD9xtC3oAar4y9AhAUksIyGi9XsZrlDZlAuMNYp9ME=";
      };
    in
    pkgs.runCommand "unzip-anime4k-shaders"
      {
        buildInputs = [ pkgs.unzip ];
        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      ''
        mkdir -p $out
        unzip -j ${src} "shaders/*" -d $out
      '';
}
