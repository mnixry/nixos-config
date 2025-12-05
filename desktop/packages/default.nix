{ inputs, extraLibs, ... }:
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
      pkgsNoConfig = import prev.path { inherit (prev.stdenv.hostPlatform) system; };
      pkgsStable = import inputs.nixpkgs-stable { inherit (prev.stdenv.hostPlatform) system; };
    })
    (final: prev: {
      # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
      kdePackages = prev.kdePackages // {
        plasma-workspace =
          let
            # the package we want to override
            basePkg = prev.kdePackages.plasma-workspace;
            # a helper package that merges all the XDG_DATA_DIRS into a single directory
            xdgdataPkg = final.stdenv.mkDerivation {
              name = "${basePkg.name}-xdgdata";
              buildInputs = [ basePkg ];
              dontUnpack = true;
              dontFixup = true;
              dontWrapQtApps = true;
              installPhase = ''
                mkdir -p $out/share
                ( IFS=:
                  for DIR in $XDG_DATA_DIRS; do
                    if [[ -d "$DIR" ]]; then
                      cp -r $DIR/. $out/share/
                      chmod -R u+w $out/share
                    fi
                  done
                )
              '';
            };
            # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
            # script and instead inject the path of the above helper package
            derivedPkg = basePkg.overrideAttrs {
              preFixup = ''
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index+0))]"
                    unset -v "qtWrapperArgs[$((index+1))]"
                    unset -v "qtWrapperArgs[$((index+2))]"
                    unset -v "qtWrapperArgs[$((index+3))]"
                  fi
                done
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
            };
          in
          derivedPkg;
      };
    })
    (final: prev: {
      ida-pro = prev.callPackage ./ida-pro.nix { inherit (extraLibs) base64Decode; };
      ida-pro-mcp = prev.callPackage ./ida-pro-mcp.nix { };
    })
    (final: prev: {
      nixpaks = {
        telegram = wrapper prev ./nixpaks-telegram.nix;
        larksuite = wrapper prev ./nixpaks-larksuite.nix;
        qq = wrapper prev ./nixpaks-qq.nix;
        wechat = wrapper prev ./nixpaks-wechat.nix;
        spotify = wrapper prev ./nixpaks-spotify.nix;
        wpsoffice = wrapper prev ./nixpaks-wpsoffice.nix;
        wemeet = wrapper prev ./nixpaks-wemeet.nix;
      };
    })
  ];
}
