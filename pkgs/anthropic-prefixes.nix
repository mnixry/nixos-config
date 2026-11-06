{
  runCommandLocal,
  cacert,
  curl,
  jq,
}:
runCommandLocal "anthropic-prefixes"
  {
    outputHash = "sha256-dkhpu2XU86HNEInn3Q2a/r4xkNhy44ySCCt25RUpgQI=";
    nativeBuildInputs = [
      cacert
      curl
      jq
    ];
  }
  ''
    set -euo pipefail
    curl -fsSL 'https://platform.claude.com/docs/en/api/ip-addresses.md' |
      jq -eRsr '[scan("[0-9a-fA-F.:]+/[0-9]+")] | unique | select(length > 0) | join("\n")' > "$out"
  ''
