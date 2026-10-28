{ pkgs, ... }:
let
  script = pkgs.writers.writeNu "corplink-scope" (builtins.readFile ./corplink-scope.nu);
in
{
  launchd.daemons.corplink-scope = {
    command = "${script}";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/corplink-scope.log";
      StandardErrorPath = "/var/log/corplink-scope.log";
    };
  };
}
