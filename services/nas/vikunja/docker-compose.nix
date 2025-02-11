# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  config,
  uptix,
  secrets,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."vikunja-db" = {
    image = uptix.dockerImage "lscr.io/linuxserver/mariadb:latest";
    environment = {
      "MYSQL_DATABASE" = "vikunja";
      "MYSQL_USER" = "vikunja";
    };
    volumes = [
      "${config.serviceOpts.dockerDir}/vikunja/db:/var/lib/mysql:rw"
    ];
    #cmd = ["--character-set-server=utf8mb4" "--collation-server=utf8mb4_unicode_ci"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=mysqladmin ping -h localhost -u $MYSQL_USER --password=$MYSQL_PASSWORD"
      "--health-interval=2s"
      "--health-start-period=30s"
      "--network-alias=db"
      "--network=vikunja_default"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/vikunja/env-db"
    ];
  };
  systemd.services."docker-vikunja-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-vikunja_default.service"
    ];
    requires = [
      "docker-network-vikunja_default.service"
    ];
    partOf = [
      "docker-compose-vikunja-root.target"
    ];
    wantedBy = [
      "docker-compose-vikunja-root.target"
    ];
  };
  virtualisation.oci-containers.containers."vikunja-app" = {
    image = uptix.dockerImage "vikunja/vikunja";
    environment = {
      "VIKUNJA_DATABASE_DATABASE" = "vikunja";
      "VIKUNJA_DATABASE_HOST" = "db";
      "VIKUNJA_DATABASE_TYPE" = "mysql";
      "VIKUNJA_DATABASE_USER" = "vikunja";
      "VIKUNJA_SERVICE_PUBLICURL" = "https://todo.${secrets.selfhosting.domain}";
    };
    volumes = [
      "${config.serviceOpts.dockerDir}/vikunja/config:/app/vikunja/files:rw"
    ];
    dependsOn = [
      "vikunja-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=vikunja"
      "--network=proxynet"
      "--network=vikunja_default"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/vikunja/env-app"
    ];
  };
  systemd.services."docker-vikunja-app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-vikunja_default.service"
    ];
    requires = [
      "docker-network-vikunja_default.service"
    ];
    partOf = [
      "docker-compose-vikunja-root.target"
    ];
    wantedBy = [
      "docker-compose-vikunja-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-vikunja_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f vikunja_default";
    };
    script = ''
      docker network inspect vikunja_default || docker network create vikunja_default
    '';
    partOf = ["docker-compose-vikunja-root.target"];
    wantedBy = ["docker-compose-vikunja-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-vikunja-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
