{
  pkgs,
  lib,
  vars,
  ...
}:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    liveRestore = true;
    extraPackages = [ pkgs.youki ];
    daemon.settings = {
      experimental = true;
      ipv6 = true;
      userland-proxy = false;
      #       default-runtime = "youki";
      runtimes.youki.path = lib.getExe pkgs.youki;
    };
  };

  users.users."${vars.user.name}".extraGroups = [ "docker" ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer-ce = {
      # Pulls from docker hub.
      image = "portainer/portainer-ce:alpine-sts";
      serviceName = "portainer";
      # Drive mappings to system folders.
      volumes = [
        # This is where portainer-ce stores it's internal data and
        # databases
        "portainer_data:/data"
        # This is so portainer can access and control the systems
        # docker version.
        "/var/run/docker.sock:/var/run/docker.sock"
        # So logging matches local time. Unless you *like* doing
        # that sort of math?!
        "/etc/localtime:/etc/localtime:ro"
      ];
      ports = [ "127.0.0.1:9443:9443" ];
      autoStart = true;
      pull = "always";
    };
  };

  systemd.services."portainer" = {
    requires = [ "dae.service" ];
  };
}
