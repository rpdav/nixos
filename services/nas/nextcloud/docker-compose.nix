# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  serviceOpts,
  uptix,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."nextcloud" = {
    image = uptix.dockerImage "lscr.io/linuxserver/nextcloud";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
    };
    volumes = [
      "/mnt/docker/nextcloud/:/data:rw"
      "${serviceOpts.dockerDir}/nextcloud/config:/config:rw"
    ];
    dependsOn = [
      "nextcloud-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=nextcloud"
      "--network=nextcloud_default"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-nextcloud" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-nextcloud_default.service"
    ];
    requires = [
      "docker-network-nextcloud_default.service"
    ];
    partOf = [
      "docker-compose-nextcloud-root.target"
    ];
    wantedBy = [
      "docker-compose-nextcloud-root.target"
    ];
  };
  virtualisation.oci-containers.containers."nextcloud-db" = {
    image = uptix.dockerImage "lscr.io/linuxserver/mariadb";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
    };
    volumes = [
      "${serviceOpts.dockerDir}/nextcloud/db:/config:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=nextcloud_default"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/nextcloud/env"
    ];
  };
  systemd.services."docker-nextcloud-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-nextcloud_default.service"
    ];
    requires = [
      "docker-network-nextcloud_default.service"
    ];
    partOf = [
      "docker-compose-nextcloud-root.target"
    ];
    wantedBy = [
      "docker-compose-nextcloud-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-nextcloud_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f nextcloud_default";
    };
    script = ''
      docker network inspect nextcloud_default || docker network create nextcloud_default
    '';
    partOf = ["docker-compose-nextcloud-root.target"];
    wantedBy = ["docker-compose-nextcloud-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-nextcloud-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
