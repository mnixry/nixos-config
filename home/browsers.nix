{
  lib,
  pkgs,
  config,
  ...
}:

{
  xdg.mimeApps.defaultApplicationPackages = [
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
    profiles.dev-edition-default.settings =
      let
        mkFontSettings =
          type: prefix:
          lib.attrsets.mapAttrs' (
            name: value: lib.nameValuePair "font.name.${type}.${name}" "${prefix} ${value}"
          );
        fontSettings = (
          {
            "layout.css.system-ui.enabled" = false;
            "font.language.group" = "x-western";
            "font.default.x-western" = "sans-serif";
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
          }
        );
        # Ref: https://github.com/arkenfox/user.js/
        privacySettings = {
          # 0000: disable about:config warning **
          "browser.aboutConfig.showWarning" = false;
          # 0320: disable recommendation pane in about:addons (uses Google Analytics) **
          "extensions.getAddons.showPane" = false;
          # 0321: disable recommendations in about:addons' Extensions and Themes panes [FF68+] **
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          # 0322: disable personalized Extension Recommendations in about:addons and AMO [FF65+]
          "browser.discovery.enabled" = false;
          # 0335: disable Firefox Home (Activity Stream) telemetry **
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          # 0340: disable Studies
          "app.shield.optoutstudies.enabled" = false;
          # 0341: disable Normandy/Shield [FF60+]
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          # 0350: disable Crash Reports **
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false; # [FF44+]
          "browser.crashReports.unsubmittedCheck.enabled" = false; # [FF51+] [DEFAULT: false]
          # 0351: enforce no submission of backlogged Crash Reports [FF58+]
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # [DEFAULT: false]
          # 0601: disable link prefetching
          "network.prefetch-next" = false;
          # 0602: disable DNS prefetching
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;
          # 0603: disable predictor / prefetching **
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false; # [FF48+] [DEFAULT: false]
          # 0604: disable link-mouseover opening connection to linked server
          "network.http.speculative-parallel-limit" = 0;
          # 0605: disable mousedown speculative connections on bookmarks and history [FF98+] **
          "browser.places.speculativeConnect.enabled" = false;
          # 0702: set the proxy server to do any DNS lookups when using SOCKS
          "network.proxy.socks_remote_dns" = true;
        };
      in
      (
        {
          "places.history.expiration.max_pages" = 128 * 1024 * 1024;
          "media.ffmpeg.vaapi.enabled" = true;
          "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        }
        // fontSettings
        // privacySettings
      );
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
