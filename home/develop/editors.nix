{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    (code-cursor.overrideAttrs (_: {
      # force cursor to use system built Electron
      postInstall =
        let
          electron = lib.getExe pkgs.electron;
          cursor-agent = lib.getExe pkgs.cursor-cli;
        in
        ''
          substituteInPlace "$out/bin/cursor" \
            --replace-fail '~/.local/bin/cursor-agent' '${cursor-agent}' \
            --replace-fail '$VSCODE_PATH/cursor' '${electron}' \
            --replace-fail \
              'ELECTRON_RUN_AS_NODE=1 \"$ELECTRON\" \"$CLI\"'\
              'ELECTRON_RUN_AS_NODE=1 \"$ELECTRON\" \"$CLI\" --app \"$VSCODE_PATH/resources/app\"'
        '';
    }))
    (jetbrains.datagrip.override { forceWayland = true; })
    (jetbrains.idea.override { forceWayland = true; })
  ];
  programs.vscode.enable = true;
}
