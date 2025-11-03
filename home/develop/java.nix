{ lib, pkgs, ... }:
let
  defaultJdk = pkgs.zulu.override { enableJavaFX = true; };
  mkJdkOverride = pkg: pkg.override { jdk = defaultJdk; };
in
{
  home.packages = (
    with pkgs;
    [
      defaultJdk
      (mkJdkOverride jadx)
    ]
  );
  home.shellAliases = (
    builtins.foldl' (
      acc: name:
      let
        matched = builtins.match "zulu([[:digit:]]+)" name;
        version = lib.elemAt matched 0;
        package = lib.getExe (pkgs.${name}.override { enableJavaFX = true; });
      in
      acc // lib.optionalAttrs (matched != null) { "java${version}" = package; }
    ) { } (builtins.attrNames pkgs)
  );
}
