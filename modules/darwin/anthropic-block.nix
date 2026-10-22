{ pkgs, ... }:
let
  pfRules = pkgs.writeText "anthropic.pf" ''
    table <anthropic> persist file "${pkgs.anthropic-prefixes}"

    rdr on lo0 inet proto tcp from any to <anthropic> -> 127.0.0.1 port 7893

    # Replies to local TUN addresses must return through loopback.
    pass in quick on lo0 reply-to (lo0 127.0.0.1) inet proto tcp from any to 127.0.0.1 port 7893 keep state
    pass out quick route-to (lo0 127.0.0.1) inet proto tcp from any to <anthropic> no state

    block return-rst out quick proto tcp from any to <anthropic>
    block return-icmp(filter-prohib) out quick inet from any to <anthropic>
    block return-icmp6(admin-unr) out quick inet6 from any to <anthropic>
  '';
in
{
  launchd.daemons.anthropic-block = {
    command = "/sbin/pfctl -E -a com.apple/anthropic-block -f ${pfRules}";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
    };
  };
}
