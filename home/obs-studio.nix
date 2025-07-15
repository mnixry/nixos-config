{ pkgs, lib, ... }:
{
  programs.obs-studio = {
    enable = pkgs.stdenv.isx86_64;
    plugins =
      with pkgs.obs-studio-plugins;
      [
        # screen capture
        wlrobs
        # obs-ndi
        # obs-nvfbc
        obs-teleport
        # obs-hyperion
        droidcam-obs
        obs-vkcapture
        obs-gstreamer
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        obs-shaderfilter
        obs-source-record
        obs-livesplit-one
        looking-glass-obs
        obs-vintage-filter
        obs-command-source
        obs-move-transition
        obs-backgroundremoval
        # advanced-scene-switcher
        obs-pipewire-audio-capture
      ]
      ++ (lib.optionals pkgs.stdenv.isx86_64 [
        obs-vaapi
        obs-3d-effect
      ]);
  };
}
