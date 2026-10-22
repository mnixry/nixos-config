{ pkgs, ... }:
let
  nftRules =
    pkgs.runCommandLocal "anthropic-block.nft"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        jq -Rn -r '
          [inputs] as $prefixes
          | ($prefixes | map(select(contains(":") | not)) | join(", ")) as $v4
          | ($prefixes | map(select(contains(":"))) | join(", ")) as $v6
          | [
            "set v4 {",
            "  type ipv4_addr",
            "  flags interval",
            "  elements = { \($v4) }",
            "}",
            "set v6 {",
            "  type ipv6_addr",
            "  flags interval",
            "  elements = { \($v6) }",
            "}",
            "chain output {",
            "  type filter hook output priority filter; policy accept;",
            "  ip daddr @v4 drop",
            "  ip6 daddr @v6 drop",
            "}",
            "chain forward {",
            "  type filter hook forward priority filter; policy accept;",
            "  ip daddr @v4 drop",
            "  ip6 daddr @v6 drop",
            "}"
          ]
          | join("\n")
        ' ${pkgs.anthropic-prefixes} > "$out"
      '';
in
{
  networking.nftables = {
    enable = true;
    tables.anthropic-block = {
      family = "inet";
      content = ''
        include "${nftRules}"
      '';
    };
  };

  virtualisation.docker.daemon.settings."firewall-backend" = "nftables";
  virtualisation.libvirtd.firewallBackend = "nftables";
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
}
