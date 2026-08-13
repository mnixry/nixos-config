# Credits: https://github.com/msanft/ida-pro-overlay/blob/main/packages/ida-pro.nix
{
  pkgs,
  lib,
  genuineDecrypt,
  ...
}:
let
  installScript =
    lib.pipe
      ''
        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
        04bhZ5ld3fatB/SW
      ''
      [
        (genuineDecrypt "5971cd58c8acb930c6a394e9a2aa58e070342271")
        (pkgs.writers.writePython3Bin "script" { doCheck = false; })
        lib.getExe
      ];
  pythonForIDA = pkgs.python313.withPackages (
    ps: with ps; [
      rpyc
      z3-solver
      # https://github.com/NixOS/nixpkgs/pull/487341
      # angr
    ]
  );
in
pkgs.stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.3.260213";

  src = pkgs.fetchurl {
    url = "https://archive.org/download/ida-pro_93_x64linux/ida-pro_93_x64linux.run";
    hash = "sha256-LtQ65LuE103K5vAJkhDfqNYb/qSVL1+aB6mq4Wy3D4I=";
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

    libice
    libsm
    libx11
    libxau
    libxcb
    libxext
    libxi
    libxrender
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm

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
