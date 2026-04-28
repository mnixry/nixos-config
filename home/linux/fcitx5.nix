{ pkgs, config, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-fluent
        fcitx5-mellow-themes
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
            rime-moegirl
            rime-zhwiki
          ];
        })
      ];
      settings = {
        inputMethod = {
          "GroupOrder" = {
            "0" = "default";
          };
          "Groups/0" = {
            "Name" = "default";
            "DefaultIM" = "rime";
            "Default Layout" = "us";
          };
          "Groups/0/Items/0" = {
            "Name" = "keyboard-us";
            "Layout" = "";
          };
          "Groups/0/Items/1" = {
            "Name" = "rime";
            "Layout" = "us";
          };
        };
        globalOptions = {
          "Hotkey" = {
            "TriggerKeys" = "";
            "EnumerateWithTriggerKeys" = "True";
            "AltTriggerKeys" = "";
            "EnumerateBackwardKeys" = "";
            "EnumerateSkipFirst" = "False";
            "ModifierOnlyKeyTimeout" = "250";
          };
          "Hotkey/EnumerateForwardKeys" = {
            "0" = "Control+Shift+Shift_L";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          "Hotkey/ActivateKeys" = {
            "0" = "Hangul_Hanja";
          };
          "Hotkey/DeactivateKeys" = {
            "0" = "Hangul_Romaja";
          };
          "Hotkey/PrevPage" = {
            "0" = "Up";
          };
          "Hotkey/NextPage" = {
            "0" = "Down";
          };
          "Hotkey/PrevCandidate" = {
            "0" = "Shift+Tab";
          };
          "Hotkey/NextCandidate" = {
            "0" = "Tab";
          };
          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };
          "Behavior" = {
            "ActiveByDefault" = "False";
            "resetStateWhenFocusIn" = "No";
            "ShareInputState" = "No";
            "PreeditEnabledByDefault" = "True";
            "ShowInputMethodInformation" = "True";
            "showInputMethodInformationWhenFocusIn" = "False";
            "CompactInputMethodInformation" = "True";
            "ShowFirstInputMethodInformation" = "True";
            "DefaultPageSize" = "5";
            "OverrideXkbOption" = "False";
            "CustomXkbOption" = "";
            "EnabledAddons" = "";
            "DisabledAddons" = "";
            "PreloadInputMethod" = "True";
            "AllowInputMethodForPassword" = "False";
            "ShowPreeditForPassword" = "False";
            "AutoSavePeriod" = "30";
          };
        };
        addons = {
          classicui.globalSection = {
            # Font = "Noto Sans CJK SC 12";
            # MenuFont = "Sans Serif 12";
            # TrayFont = "Sans Serif 12";
            Theme = "FluentDark"; # FluentDark-solid/mellow-youlan-dark
          };
          clipboard = {
            globalSection = {
              "TriggerKey" = "";
            };
            # sections.TriggerKey = {
            #   "0" = "Control+Alt+semicolon";
            # };
          };
          notifications = {
            globalSection = { };
            sections.HiddenNotifications = {
              "0" = "fcitx-rime-deploy";
            };
          };
        };
      };
    };
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml".source =
    let
      toYAML = (pkgs.formats.yaml { }).generate "default.custom.yaml";
    in
    toYAML {
      patch = {
        __include = "rime_ice_suggestion:/";
        schema_list = [ { schema = "rime_ice"; } ];
        ascii_composer.switch_key = {
          # commit_code | commit_text | inline_ascii | clear | noop
          Shift_L = "commit_code";
          Shift_R = "commit_code";
        };
        menu.page_size = 6;
        switcher.hotkeys = [ "Control+F4" ];
      };
    };

  programs.plasma.configFile.kwinrc."Wayland"."InputMethod" = {
    value = "${config.home.profileDirectory}/share/applications/fcitx5-wayland-launcher.desktop";
    shellExpand = true;
  };
}
