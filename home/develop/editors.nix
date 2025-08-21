{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    (code-cursor.overrideAttrs (_: {
      # force cursor to use system built Electron
      postInstall =
        let
          electron = lib.getExe pkgs.electron;
        in
        ''
          sed -i \
            -e "/ELECTRON=/iVSCODE_PATH='$out/lib/cursor'" \
            -e 's|^ELECTRON=.*|ELECTRON=${electron}|' \
            -e 's|ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@"|ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" --app "$VSCODE_PATH/resources/app" "$@"|' \
            "$out/bin/cursor"
        '';
    }))
  ];
  programs.vscode.enable = true;
}
