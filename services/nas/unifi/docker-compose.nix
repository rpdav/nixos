# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  serviceOpts,
  uptix,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."unifi-db" = {
    image = "mongo:7.0";
    volumes = [
      "${serviceOpts.dockerDir}/unifi-network-application/db:/data/db:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=dbnet"
      "--network=unifi_default"
    ];
  };
  systemd.services."docker-unifi-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-unifi_default.service"
    ];
    requires = [
      "docker-network-unifi_default.service"
    ];
    partOf = [
      "docker-compose-unifi-root.target"
    ];
    wantedBy = [
      "docker-compose-unifi-root.target"
    ];
  };
  virtualisation.oci-containers.containers."unifi-network-application" = {
    image = uptix.dockerImage "lscr.io/linuxserver/unifi-network-application";
    environment = {
      "MEM_LIMIT" = "1024";
      "MEM_STARTUP" = "1024";
      "MONGO_AUTHSOURCE" = "";
      "MONGO_DBNAME" = "unifi";
      "MONGO_HOST" = "unifi-db";
      "MONGO_PORT" = "27017";
      "MONGO_TLS" = "";
      "MONGO_USER" = "unifi";
      "PGID" = "100";
      "PUID" = "1000";
    };
    volumes = [
      "${serviceOpts.dockerDir}/unifi-network-application/config:/config:rw"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/unifi-network-application/env"
    ];
    ports = [
      "8443:8443/tcp"
      "3478:3478/udp"
      "10001:10001/udp"
      "8080:8080/tcp"
      "1900:1900/udp"
      "8843:8843/tcp"
      "8880:8880/tcp"
      "6789:6789/tcp"
      "5514:5514/udp"
    ];
    dependsOn = [
      "unifi-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=unifi-network-application"
      "--network=proxynet"
      "--network=unifi_default"
    ];
  };
  systemd.services."docker-unifi-network-application" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-unifi_default.service"
    ];
    requires = [
      "docker-network-unifi_default.service"
    ];
    partOf = [
      "docker-compose-unifi-root.target"
    ];
    wantedBy = [
      "docker-compose-unifi-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-unifi_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f unifi_default";
    };
    script = ''
      docker network inspect unifi_default || docker network create unifi_default
    '';
    partOf = ["docker-compose-unifi-root.target"];
    wantedBy = ["docker-compose-unifi-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-unifi-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
