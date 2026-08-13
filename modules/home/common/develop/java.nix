{ lib, pkgs, ... }:
let
  defaultJdk = pkgs.zulu.override { enableJavaFX = true; };
in
{
  home.packages =
    with pkgs;
    [ defaultJdk ]
    ++ lib.optionals stdenv.isLinux [
      (jadx.overrideAttrs (
        # FIXME: jadx is relying on Gradle 8, which does not compatible with Jetbrains JDK (JDK 25)
        { installPhase, ... }:
        let
          jdkHome = builtins.unsafeDiscardStringContext (toString jdk.home);
          jetbrainsJdkHome = builtins.unsafeDiscardStringContext (toString jetbrains.jdk.home);
        in
        {
          installPhase =
            builtins.seq
              (lib.assertMsg (lib.strings.hasInfix jdkHome installPhase) "jadx is not using the correct JDK")
              (lib.strings.replaceString jdkHome jetbrainsJdkHome installPhase);
        }
      ))
    ];
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
