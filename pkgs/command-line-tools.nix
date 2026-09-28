{
  lib,
  linkFarm,
  stdenv,
  apple-sdk,
  cctools,
  darwin,
  git,
  gnumake,
  python3,
  xcbuild,
}:
let
  binaries = lib.mergeAttrsList (
    map ({ package, names }: lib.genAttrs names (lib.getExe' package)) [
      {
        package = git;
        names = [
          "git"
          "git-receive-pack"
          "git-shell"
          "git-upload-archive"
          "git-upload-pack"
        ];
      }
      {
        package = stdenv.cc;
        names = [
          "clang"
          "clang++"
          "cc"
          "c++"
          "cpp"
        ];
      }
      {
        package = gnumake;
        names = [ "make" ];
      }
      {
        package = python3.withPackages (ps: [ ps.pip ]);
        names = [
          "python3"
          "pip3"
        ];
      }
      {
        package = stdenv.cc.bintools;
        names = [
          "ar"
          "as"
          "ld"
          "nm"
          "objdump"
          "ranlib"
          "size"
          "strings"
          "strip"
        ];
      }
      {
        package = darwin.binutils-unwrapped;
        names = [
          "codesign_allocate"
          "dsymutil"
          "dwarfdump"
          "install_name_tool"
          "lipo"
          "otool"
        ];
      }
      {
        package = cctools.libtool;
        names = [ "libtool" ];
      }
      {
        package = cctools;
        names = [ "vtool" ];
      }
      {
        package = xcbuild.xcrun;
        names = [ "xcrun" ];
      }
    ]
  );
  aliases = lib.mapAttrs (_: name: binaries.${name}) {
    gcc = "clang";
    "g++" = "clang++";
    gnumake = "make";
  };
in
linkFarm "nix-command-line-tools" (
  {
    Platforms = "${apple-sdk}/Platforms";
    Toolchains = "${apple-sdk}/Toolchains";
  }
  // lib.mapAttrs' (name: path: lib.nameValuePair "usr/bin/${name}" path) (binaries // aliases)
)
