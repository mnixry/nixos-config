{
  runCommandLocal,
  cacert,
  curl,
  jq,
}:
runCommandLocal "anthropic-as399358-prefixes"
  {
    outputHash = "sha256-yX1WmQEUf6XiLtmxvk0iskPoqBbEm7fhvFWKfTgrz6M=";
    nativeBuildInputs = [
      cacert
      curl
      jq
    ];
  }
  ''
    set -euo pipefail
    curl -fsS \
      'https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS399358&min_peers_seeing=1' |
      jq -er '[.data.prefixes[].prefix] | unique | join("\n")' > "$out"
  ''
