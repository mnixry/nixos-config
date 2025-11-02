#https://github.com/msanft/ida-pro-overlay/blob/main/packages/ida-pro.nix
{
  pkgs,
  lib,
  ...
}:
let
  installScript =
    lib.pipe
      ''
        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
        YtITAAA=
      ''
      [
        lib.escapeShellArg
        (content: pkgs.runCommand "base64-decode" { } "echo ${content} | base64 -d | gzip -d > $out")
        builtins.readFile
        (pkgs.writers.writePython3Bin "script" { doCheck = false; })
        lib.getExe
      ];
  pythonForIDA = pkgs.python313.withPackages (ps: with ps; [ rpyc ]);
in
pkgs.stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.2";

  src = pkgs.fetchurl {
    url = "https://archive.org/download/ida-pro_92/ida-pro_92_x64linux.run";
    hash = "sha256-EXzWJftWzuxi8mnOs+XK/9jMUWvxdHafi6F4Xs2ayVI=";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "ida-pro";
    exec = "ida";
    icon = pkgs.fetchurl {
      url = "https://github.com/msanft/ida-pro-overlay/raw/refs/heads/main/share/appico.png";
      hash = "sha256-u2o3FGNtxzPNizF8RMWtVFbakQJwEmKD61mRybo/UEI=";
    };
    comment = meta.description;
    desktopName = "IDA Pro";
    genericName = "Interactive Disassembler";
    categories = [ "Development" ];
    startupWMClass = "IDA";
  };
  desktopItems = [ desktopItem ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];

  # We just get a runfile in $src, so no need to unpack it.
  dontUnpack = true;

  # Add everything to the RPATH, in case IDA decides to dlopen things.
  runtimeDependencies = with pkgs; [
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    qt6.qtbase
    qt6.qtwayland
    libunwind
    libxkbcommon
    libsecret
    openssl.out
    stdenv.cc.cc
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
    curl.out
    pythonForIDA
  ];
  buildInputs = runtimeDependencies;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    function print_debug_info() {
      if [ -f installbuilder_installer.log ]; then
        cat installbuilder_installer.log
      else
        echo "No debug information available."
      fi
    }

    trap print_debug_info EXIT

    mkdir -p $out/bin $out/lib $out/opt/.local/share/applications

    # IDA depends on quite some things extracted by the runfile, so first extract everything
    # into $out/opt, then remove the unnecessary files and directories.
    IDADIR="$out/opt"
    # IDA doesn't always honor `--prefix`, so we need to hack and set $HOME here.
    HOME="$out/opt"

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --debuglevel 4 --prefix $IDADIR

    (cd "$IDADIR" && ${installScript})

    # Link the exported libraries to the output.
    for lib in $IDADIR/*.so $IDADIR/*.so.6; do
      ln -s $lib $out/lib/$(basename $lib)
    done

    # Manually patch libraries that dlopen stuff.
    patchelf --add-needed libpython3.13.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so
    patchelf --add-needed libsecret-1.so.0 $out/lib/libida.so

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Link the binaries to the output.
    # Also, hack the PATH so that pythonForIDA is used over the system python.
    for bb in ida; do
      wrapProgram $IDADIR/$bb \
        --prefix IDADIR : $IDADIR \
        --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms \
        --prefix PYTHONPATH : $out/bin/idalib/python \
        --prefix PATH : ${pythonForIDA}/bin:$IDADIR \
        --prefix LD_LIBRARY_PATH : $out/lib
      ln -s $IDADIR/$bb $out/bin/$bb
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    mainProgram = "ida";
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
