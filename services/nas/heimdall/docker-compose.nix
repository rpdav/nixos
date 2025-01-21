# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  serviceOpts,
  uptix,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."heimdall" = {
    image = uptix.dockerImage "lscr.io/linuxserver/heimdall";
    environment = {
      "PGID" = "100";
      "PUID" = "1000";
    };
    volumes = [
      "${serviceOpts.dockerDir}/heimdall/config:/config:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=heimdall"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-heimdall" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    partOf = [
      "docker-compose-heimdall-root.target"
    ];
    wantedBy = [
      "docker-compose-heimdall-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-heimdall-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}