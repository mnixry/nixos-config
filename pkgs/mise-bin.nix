{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mise-bin";
  version = "2026.11.10";

  src = finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system};

  strictDeps = true;
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/mise $out/bin/mise
    install -Dm644 man/man1/mise.1 $out/share/man/man1/mise.1
    mkdir -p $out/lib/mise
    touch $out/lib/mise/.disable-self-update

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  versionCheckProgramArg = "--version";

  passthru.sources = {
    "x86_64-linux" = fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${finalAttrs.version}/mise-v${finalAttrs.version}-linux-x64.tar.xz";
      hash = "sha256-2vD42IVroQF7h2AZbEzb0qPGqlVIOe7tMcOJ7CLYZHk=";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${finalAttrs.version}/mise-v${finalAttrs.version}-linux-arm64.tar.xz";
      hash = "sha256-+XsYF5VOXYGvSJqKbLunoSGy+0sd2vsWml4byA5cOBA=";
    };
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${finalAttrs.version}/mise-v${finalAttrs.version}-macos-x64.tar.xz";
      hash = "sha256-OZi7F6ithW47IqNerNbXC7aUjRFV4+qOsy+VOysDP6w=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${finalAttrs.version}/mise-v${finalAttrs.version}-macos-arm64.tar.xz";
      hash = "sha256-JAUt9HAVtRHsJss22m42mCzB84CKyKXMFhGjUeA5+j0=";
    };
  };

  meta = {
    homepage = "https://mise.jdx.dev";
    description = "Front-end to your dev env";
    changelog = "https://github.com/jdx/mise/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "mise";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames finalAttrs.passthru.sources;
    broken = stdenvNoCC.hostPlatform.isMusl;
  };
})
