{
  lib,
  inputs,
  ...
}:
{
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
    settings = {
      keep-going = true;
      always-allow-substitutes = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkBefore [
        "https://cache.numtide.com"
        "https://nix-cache.any-mix.eu.org"
      ];
      trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "nix-cache.any-mix.eu.org-1:1arBVKbTurqBX3Foe+tO8MihDz6qmVjNgnJ/lE3p1QI="
      ];
      narinfo-cache-negative-ttl = 60;
      auto-optimise-store = false;
      http-connections = 0;
    };
    registry.short = {
      from = {
        id = "p";
        type = "indirect";
      };
      to = {
        type = "path";
        path = inputs.self;
      };
    };
  };
}
