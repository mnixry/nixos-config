{
  lib,
  pkgs,
  config,
  ...
}:
{
  xdg.mimeApps.defaultApplications = config.lib.xdg.mimeAssociations [
    config.programs.firefox.package
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
    };
    profiles.default.settings =
      let
        mkFontSettings =
          type: prefix:
          lib.attrsets.mapAttrs' (
            name: value: lib.nameValuePair "font.name.${type}.${name}" "${prefix} ${value}"
          );
      in
      {
        "layout.css.system-ui.enabled" = false;
        "font.language.group" = "x-western";
        "font.default.x-western" = "sans-serif";
        "places.history.expiration.max_pages" = 128 * 1024 * 1024;
        "media.ffmpeg.vaapi.enabled" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
      }
      // mkFontSettings "monospace" "Sarasa Term" {
        "ja" = "J";
        "ko" = "K";
        "zh-CN" = "SC";
        "zh-HK" = "HC";
        "zh-TW" = "CL";
      }
      // mkFontSettings "sans-serif" "Noto Sans CJK" {
        "ja" = "JP";
        "ko" = "KR";
        "zh-CN" = "SC";
        "zh-HK" = "HK";
        "zh-TW" = "TC";
      }
      // mkFontSettings "serif" "Noto Serif CJK" {
        "ja" = "JP";
        "ko" = "KR";
        "zh-CN" = "SC";
        "zh-HK" = "HK";
        "zh-TW" = "TC";
      };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
