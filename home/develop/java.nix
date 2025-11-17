{ lib, pkgs, ... }:
let
  defaultJdk = pkgs.zulu.override { enableJavaFX = true; };
in
{
  home.packages = (
    with pkgs;
    [
      defaultJdk
      (jadx.override { inherit (jetbrains) jdk; })
    ]
  );
  home.shellAliases = (
    builtins.foldl' (
      acc: name:
      let
        matched = builtins.match "zulu([[:digit:]]+)" name;
        version = lib.elemAt matched 0;
        package = builtins.tryEval (lib.getExe (pkgs.${name}.override { enableJavaFX = true; }));
      in
      acc // lib.optionalAttrs (matched != null && package.success) { "java${version}" = package.value; }
    ) { } (builtins.attrNames pkgs)
  );
}
