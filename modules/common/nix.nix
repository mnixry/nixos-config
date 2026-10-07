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
        "ca-derivations"
        "pipe-operators"
      ];
      substituters = lib.mkBefore [
        "https://nix-cache.any-mix.eu.org"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = lib.mkBefore [
        "nix-cache.any-mix.eu.org-1:1arBVKbTurqBX3Foe+tO8MihDz6qmVjNgnJ/lE3p1QI="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
      narinfo-cache-negative-ttl = 60;
      auto-optimise-store = false;
      http-connections = 0;
      max-substitution-jobs = 32;
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
