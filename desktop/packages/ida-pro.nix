#https://github.com/msanft/ida-pro-overlay/blob/main/packages/ida-pro.nix
{
  pkgs,
  lib,
  base64Decode,
  ...
}:
let
  installScript =
    lib.pipe
      ''
        IyAtKi0gY29kaW5nOiB1dGYtOCAtKi0KCmltcG9ydCBqc29uCmltcG9ydCBoYXNobGliCmltcG9y
        dCBvcwppbXBvcnQgcGxhdGZvcm0KCmxpY2Vuc2UgPSB7CiAgICAiaGVhZGVyIjogeyJ2ZXJzaW9u
        IjogMX0sCiAgICAicGF5bG9hZCI6IHsKICAgICAgICAibmFtZSI6ICJJREFQUk85IiwKICAgICAg
        ICAiZW1haWwiOiAiaWRhcHJvOUBleGFtcGxlLmNvbSIsCiAgICAgICAgImxpY2Vuc2VzIjogWwog
        ICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAiaWQiOiAiNDgtMjEzNy1BQ0FCLTk5IiwKICAg
        ICAgICAgICAgICAgICJlZGl0aW9uX2lkIjogImlkYS1wcm8iLAogICAgICAgICAgICAgICAgImRl
        c2NyaXB0aW9uIjogImxpY2Vuc2UiLAogICAgICAgICAgICAgICAgImxpY2Vuc2VfdHlwZSI6ICJu
        YW1lZCIsCiAgICAgICAgICAgICAgICAicHJvZHVjdCI6ICJJREEiLAogICAgICAgICAgICAgICAg
        InByb2R1Y3RfaWQiOiAiSURBUFJPIiwKICAgICAgICAgICAgICAgICJwcm9kdWN0X3ZlcnNpb24i
        OiAiOS4yIiwKICAgICAgICAgICAgICAgICJzZWF0cyI6IDEsCiAgICAgICAgICAgICAgICAic3Rh
        cnRfZGF0ZSI6ICIyMDI0LTA4LTEwIDAwOjAwOjAwIiwKICAgICAgICAgICAgICAgICJlbmRfZGF0
        ZSI6ICIyMDMzLTEyLTMxIDIzOjU5OjU5IiwKICAgICAgICAgICAgICAgICJpc3N1ZWRfb24iOiAi
        MjAyNC0wOC0xMCAwMDowMDowMCIsCiAgICAgICAgICAgICAgICAib3duZXIiOiAiSGV4UmF5cyIs
        CiAgICAgICAgICAgICAgICAiYWRkX29ucyI6IFtdLAogICAgICAgICAgICAgICAgImZlYXR1cmVz
        IjogW10sCiAgICAgICAgICAgIH0KICAgICAgICBdLAogICAgfSwKfQoKCmRlZiBhZGRfZXZlcnlf
        YWRkb24obGljZW5zZSk6CiAgICBwbGF0Zm9ybXMgPSBbCiAgICAgICAgIlciLCAgIyBXaW5kb3dz
        CiAgICAgICAgIkwiLCAgIyBMaW51eAogICAgICAgICJNIiwgICMgbWFjT1MKICAgIF0KICAgIGFk
        ZG9ucyA9IFsKICAgICAgICAiSEVYWDg2IiwKICAgICAgICAiSEVYWDY0IiwKICAgICAgICAiSEVY
        QVJNIiwKICAgICAgICAiSEVYQVJNNjQiLAogICAgICAgICJIRVhNSVBTIiwKICAgICAgICAiSEVY
        TUlQUzY0IiwKICAgICAgICAiSEVYUFBDIiwKICAgICAgICAiSEVYUFBDNjQiLAogICAgICAgICJI
        RVhSVjY0IiwKICAgICAgICAiSEVYQVJDIiwKICAgICAgICAiSEVYQVJDNjQiLAogICAgXQoKICAg
        IGkgPSAwCiAgICBmb3IgYWRkb24gaW4gYWRkb25zOgogICAgICAgIGkgKz0gMQogICAgICAgIGxp
        Y2Vuc2VbInBheWxvYWQiXVsibGljZW5zZXMiXVswXVsiYWRkX29ucyJdLmFwcGVuZCgKICAgICAg
        ICAgICAgewogICAgICAgICAgICAgICAgImlkIjogZiI0OC0xMzM3LTAwMDAte2k6MDJ9IiwKICAg
        ICAgICAgICAgICAgICJjb2RlIjogYWRkb24sCiAgICAgICAgICAgICAgICAib3duZXIiOiBsaWNl
        bnNlWyJwYXlsb2FkIl1bImxpY2Vuc2VzIl1bMF1bImlkIl0sCiAgICAgICAgICAgICAgICAic3Rh
        cnRfZGF0ZSI6ICIyMDI0LTA4LTEwIDAwOjAwOjAwIiwKICAgICAgICAgICAgICAgICJlbmRfZGF0
        ZSI6ICIyMDMzLTEyLTMxIDIzOjU5OjU5IiwKICAgICAgICAgICAgfQogICAgICAgICkKCgphZGRf
        ZXZlcnlfYWRkb24obGljZW5zZSkKCgpkZWYganNvbl9zdHJpbmdpZnlfYWxwaGFiZXRpY2FsKG9i
        aik6CiAgICByZXR1cm4ganNvbi5kdW1wcyhvYmosIHNvcnRfa2V5cz1UcnVlLCBzZXBhcmF0b3Jz
        PSgiLCIsICI6IikpCgoKZGVmIGJ1Zl90b19iaWdpbnQoYnVmKToKICAgIHJldHVybiBpbnQuZnJv
        bV9ieXRlcyhidWYsIGJ5dGVvcmRlcj0ibGl0dGxlIikKCgpkZWYgYmlnaW50X3RvX2J1ZihpKToK
        ICAgIHJldHVybiBpLnRvX2J5dGVzKChpLmJpdF9sZW5ndGgoKSArIDcpIC8vIDgsIGJ5dGVvcmRl
        cj0ibGl0dGxlIikKCgojIFl1cCwgeW91IG9ubHkgaGF2ZSB0byBwYXRjaCA1YyAtPiBjYiBpbiBs
        aWJpZGE2NC5zbwpwdWJfbW9kdWx1c19oZXhyYXlzID0gYnVmX3RvX2JpZ2ludCgKICAgIGJ5dGVz
        LmZyb21oZXgoCiAgICAgICAgImVkZmQ0MjVjZjk3ODU0NmU4OTExMjI1ODg0NDM2YzU3MTQwNTI1
        NjUwYmNmNmViZmU4MGVkYmM1ZmIxZGU2OGY0YzY2YzI5Y2IyMmViNjY4Nzg4YWZjYjBhYmJiNzE4
        MDQ0NTg0YjgxMGY4OTcwY2RkZjIyNzM4NWY3NWQ1ZGRkZDkxZDRmMTg5MzdhMDhhYTgzYjI4YzQ5
        ZDEyZGM5MmU3NTA1YmIzODgwOWU5MWJkMGZiZDJmMmU2YWIxZDJlMzNjMGM1NWQ1YmRkZDQ3OGVl
        OGJmODQ1ZmNlZjNjODJiOWQyOTI5ZWNiNzFmNGQxYjNkYjk2ZTNhOGU3YWFmOTMiCiAgICApCikK
        cHViX21vZHVsdXNfcGF0Y2hlZCA9IGJ1Zl90b19iaWdpbnQoCiAgICBieXRlcy5mcm9taGV4KAog
        ICAgICAgICJlZGZkNDJjYmY5Nzg1NDZlODkxMTIyNTg4NDQzNmM1NzE0MDUyNTY1MGJjZjZlYmZl
        ODBlZGJjNWZiMWRlNjhmNGM2NmMyOWNiMjJlYjY2ODc4OGFmY2IwYWJiYjcxODA0NDU4NGI4MTBm
        ODk3MGNkZGYyMjczODVmNzVkNWRkZGQ5MWQ0ZjE4OTM3YTA4YWE4M2IyOGM0OWQxMmRjOTJlNzUw
        NWJiMzg4MDllOTFiZDBmYmQyZjJlNmFiMWQyZTMzYzBjNTVkNWJkZGQ0NzhlZThiZjg0NWZjZWYz
        YzgyYjlkMjkyOWVjYjcxZjRkMWIzZGI5NmUzYThlN2FhZjkzIgogICAgKQopCgpwcml2YXRlX2tl
        eSA9IGJ1Zl90b19iaWdpbnQoCiAgICBieXRlcy5mcm9taGV4KAogICAgICAgICI3N2M4NmFiYmI3
        ZjNiYjEzNDQzNjc5N2I2OGZmNDdiZWIxYTU0NTc4MTY2MDhkYmZiNzI2NDE4MTRkZDQ2NGRkNjQw
        ZDcxMWQ1NzMyZDMwMTdhMWM0ZTYzZDgzNTgyMmYwMGE0ZWFiNjE5YTJjNDc5MWNmMzNmOWY1N2Y5
        YzJhZTRkOWVlZDk5ODFlNzlhYzliOGY4YTQxMWY2OGYyNWI5ZjBjMDVkMDRkMTFlMjJhM2EwZDhk
        NDY3MmI1NmE2MWYxNTMyMjgyZmY0ZTRlNzQ3NTllODMyYjcwZTk4YjlkMTAyZDA3ZTlmYjliYThk
        MTU4MTBiMTQ0OTcwMDI5ODc0IgogICAgKQopCgoKZGVmIGRlY3J5cHQobWVzc2FnZSk6CiAgICBk
        ZWNyeXB0ZWQgPSBwb3coYnVmX3RvX2JpZ2ludChtZXNzYWdlKSwgZXhwb25lbnQsIHB1Yl9tb2R1
        bHVzX3BhdGNoZWQpCiAgICBkZWNyeXB0ZWQgPSBiaWdpbnRfdG9fYnVmKGRlY3J5cHRlZCkKICAg
        IHJldHVybiBkZWNyeXB0ZWRbOjotMV0KCgpkZWYgZW5jcnlwdChtZXNzYWdlKToKICAgIGVuY3J5
        cHRlZCA9IHBvdyhidWZfdG9fYmlnaW50KG1lc3NhZ2VbOjotMV0pLCBwcml2YXRlX2tleSwgcHVi
        X21vZHVsdXNfcGF0Y2hlZCkKICAgIGVuY3J5cHRlZCA9IGJpZ2ludF90b19idWYoZW5jcnlwdGVk
        KQogICAgcmV0dXJuIGVuY3J5cHRlZAoKCmV4cG9uZW50ID0gMHgxMwoKCmRlZiBzaWduX2hleGxp
        YyhwYXlsb2FkOiBkaWN0KSAtPiBzdHI6CiAgICBkYXRhID0geyJwYXlsb2FkIjogcGF5bG9hZH0K
        ICAgIGRhdGFfc3RyID0ganNvbl9zdHJpbmdpZnlfYWxwaGFiZXRpY2FsKGRhdGEpCgogICAgYnVm
        ZmVyID0gYnl0ZWFycmF5KDEyOCkKICAgICMgZmlyc3QgMzMgYnl0ZXMgYXJlIHJhbmRvbQogICAg
        Zm9yIGkgaW4gcmFuZ2UoMzMpOgogICAgICAgIGJ1ZmZlcltpXSA9IDB4NDIKCiAgICAjIGNvbXB1
        dGUgc2hhMjU2IG9mIHRoZSBkYXRhCiAgICBzaGEyNTYgPSBoYXNobGliLnNoYTI1NigpCiAgICBz
        aGEyNTYudXBkYXRlKGRhdGFfc3RyLmVuY29kZSgpKQogICAgZGlnZXN0ID0gc2hhMjU2LmRpZ2Vz
        dCgpCgogICAgIyBjb3B5IHRoZSBzaGEyNTYgZGlnZXN0IHRvIHRoZSBidWZmZXIKICAgIGZvciBp
        IGluIHJhbmdlKDMyKToKICAgICAgICBidWZmZXJbMzMgKyBpXSA9IGRpZ2VzdFtpXQoKICAgICMg
        ZW5jcnlwdCB0aGUgYnVmZmVyCiAgICBlbmNyeXB0ZWQgPSBlbmNyeXB0KGJ1ZmZlcikKCiAgICBy
        ZXR1cm4gZW5jcnlwdGVkLmhleCgpLnVwcGVyKCkKCgpkZWYgcGF0Y2goZmlsZW5hbWUpOgogICAg
        aWYgbm90IG9zLnBhdGguZXhpc3RzKGZpbGVuYW1lKToKICAgICAgICBwcmludChmIlNraXA6IHtm
        aWxlbmFtZX0gLSBkaWRuJ3QgZmluZCIpCiAgICAgICAgcmV0dXJuCgogICAgd2l0aCBvcGVuKGZp
        bGVuYW1lLCAicmIiKSBhcyBmOgogICAgICAgIGRhdGEgPSBmLnJlYWQoKQoKICAgICAgICBpZiBk
        YXRhLmZpbmQoYnl0ZXMuZnJvbWhleCgiRURGRDQyQ0JGOTc4IikpICE9IC0xOgogICAgICAgICAg
        ICBwcmludChmIlBhdGNoOiB7ZmlsZW5hbWV9IC0gbG9va3MgdG8gYmUgYWxyZWFkeSBwYXRjaGVk
        IDopIikKICAgICAgICAgICAgcmV0dXJuCgogICAgICAgIGlmIGRhdGEuZmluZChieXRlcy5mcm9t
        aGV4KCJFREZENDI1Q0Y5NzgiKSkgPT0gLTE6CiAgICAgICAgICAgIHByaW50KGYiUGF0Y2g6IHtm
        aWxlbmFtZX0gLSBkb2Vzbid0IGNvbnRhaW4gdGhlIG9yaWdpbmFsIG1vZHVsdXMuIikKICAgICAg
        ICAgICAgcmV0dXJuCgogICAgICAgIGRhdGEgPSBkYXRhLnJlcGxhY2UoCiAgICAgICAgICAgIGJ5
        dGVzLmZyb21oZXgoIkVERkQ0MjVDRjk3OCIpLCBieXRlcy5mcm9taGV4KCJFREZENDJDQkY5Nzgi
        KQogICAgICAgICkKCiAgICB3aXRoIG9wZW4oZmlsZW5hbWUsICJ3YiIpIGFzIGY6CiAgICAgICAg
        Zi53cml0ZShkYXRhKQoKICAgIHByaW50KGYiUGF0Y2g6IHtmaWxlbmFtZX0gLSBPSyIpCgoKbGlj
        ZW5zZVsic2lnbmF0dXJlIl0gPSBzaWduX2hleGxpYyhsaWNlbnNlWyJwYXlsb2FkIl0pCnNlcmlh
        bGl6ZWQgPSBqc29uX3N0cmluZ2lmeV9hbHBoYWJldGljYWwobGljZW5zZSkKCmZpbGVuYW1lID0g
        ImlkYXByby5oZXhsaWMiCndpdGggb3BlbihmaWxlbmFtZSwgInciKSBhcyBmOgogICAgZi53cml0
        ZShzZXJpYWxpemVkKQoKcHJpbnQoZiJcblNhdmVkIG5ldyBsaWNlbnNlIHRvIHtmaWxlbmFtZX0h
        XG4iKQoKb3NfbmFtZSA9IHBsYXRmb3JtLnN5c3RlbSgpLmxvd2VyKCkKaWYgb3NfbmFtZSA9PSAi
        d2luZG93cyI6CiAgICBwYXRjaCgiaWRhLmRsbCIpCiAgICBwYXRjaCgiaWRhMzIuZGxsIikKZWxp
        ZiBvc19uYW1lID09ICJsaW51eCI6CiAgICBwYXRjaCgibGliaWRhLnNvIikKICAgIHBhdGNoKCJs
        aWJpZGEzMi5zbyIpCmVsaWYgb3NfbmFtZSA9PSAiZGFyd2luIjoKICAgIHBhdGNoKCJsaWJpZGEu
        ZHlsaWIiKQogICAgcGF0Y2goImxpYmlkYTMyLmR5bGliIikK
      ''
      [
        base64Decode
        (pkgs.writers.writePython3Bin "script" { doCheck = false; })
        lib.getExe
      ];
  pythonForIDA = pkgs.python313.withPackages (
    ps: with ps; [
      rpyc
      z3-solver
      angr
    ]
  );
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
