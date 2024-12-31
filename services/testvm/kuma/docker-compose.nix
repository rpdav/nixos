# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  serviceOpts,
  config,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."uptime-kuma" = {
    image = "louislam/uptime-kuma:1";
    volumes = [
      "${serviceOpts.dockerDir}/uptime-kuma/config:/app/data:rw"
    ];
    ports = [
      "3001:3001/tcp"
    ];
    user = config.users.users.${serviceOpts.dockerUser}.uid;
    log-driver = "journald";
    extraOptions = [
      "--network-alias=uptime-kuma"
      "--network=swag_default"
    ];
  };
  systemd.services."docker-uptime-kuma" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-uptime-kuma-root.target"
    ];
    wantedBy = [
      "docker-compose-uptime-kuma-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-uptime-kuma-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
