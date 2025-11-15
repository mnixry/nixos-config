{ inputs, ... }:
let
  inherit (inputs) nixpak;
  wrapper =
    prev: path:
    let
      pkgs = prev;
      inherit (pkgs) lib;
    in
    pkgs.callPackage path {
      mkNixPak = nixpak.lib.nixpak {
        inherit pkgs;
        inherit lib;
      };
      mkAppWrapper =
        package:
        {
          binPath ? "bin/${builtins.baseNameOf (lib.getExe package)}",
          prefixPathes ? with pkgs; [ flatpak-xdg-utils ],
          prefixLibraries ? with pkgs; [ xorg.libX11 ],
          extraWrapperArgs ? [ ],
        }:
        let
          mainProgram = builtins.baseNameOf binPath;
          prefixPathesArg = lib.optionals (builtins.length prefixPathes > 0) [
            "--prefix"
            "PATH"
            ":"
            "${lib.makeBinPath prefixPathes}"
          ];
          prefixLibrariesArg = lib.optionals (builtins.length prefixLibraries > 0) [
            "--prefix"
            "LD_LIBRARY_PATH"
            ":"
            "${lib.makeLibraryPath prefixLibraries}"
          ];
          makeWrapperArgs = prefixPathesArg ++ prefixLibrariesArg ++ extraWrapperArgs;
        in
        (pkgs.runCommandLocal "nixpak-app-wrapper-${mainProgram}"
          {
            inherit (package) passthru;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta = { inherit mainProgram; };
          }
          ''makeWrapper '${package}/${binPath}' "$out/bin/${mainProgram}" ${lib.escapeShellArgs makeWrapperArgs}''
        );
    };
in
{
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
    (final: prev: {
      nixpaks = {
        telegram = wrapper prev ./nixpaks-telegram.nix;
        larksuite = wrapper prev ./nixpaks-larksuite.nix;
        qq = wrapper prev ./nixpaks-qq.nix;
        spotify = wrapper prev ./nixpaks-spotify.nix;
        wpsoffice = wrapper prev ./nixpaks-wpsoffice.nix;
        wemeet = wrapper prev ./nixpaks-wemeet.nix;
      };
      pkgsNoConfig = import prev.path { inherit (prev.stdenv.hostPlatform) system; };
      pkgsStable = import inputs.nixpkgs-stable { inherit (prev.stdenv.hostPlatform) system; };
      ida-pro = prev.callPackage ./ida-pro.nix { };
    })
  ];
}
