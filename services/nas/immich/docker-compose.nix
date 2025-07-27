# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  config,
  uptix,
  ...
}: let
  inherit (config) serviceOpts;
in {
  # Containers
  virtualisation.oci-containers.containers."immich_machine_learning" = {
    image = uptix.dockerImage "ghcr.io/immich-app/immich-machine-learning:release";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "${serviceOpts.dockerDir}/immich/db";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "release";
      "UPLOAD_LOCATION" = "/mnt/docker/photos/immich";
    };
    volumes = [
      "${serviceOpts.dockerDir}/immich/model-cache:/cache:rw"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/immich/env-app"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-machine-learning"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_machine_learning" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
    environment = {
      "POSTGRES_DB" = "immich";
      "POSTGRES_INITDB_ARGS" = "--data-checksums";
      "POSTGRES_USER" = "postgres";
    };
    volumes = [
      "${serviceOpts.dockerDir}/immich/db:/var/lib/postgresql/data:rw"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/immich/env-db"
    ];
    cmd = ["postgres" "-c" "shared_preload_libraries=vectors.so" "-c" "search_path=\"$user\", public, vectors" "-c" "logging_collector=on" "-c" "max_wal_size=2GB" "-c" "shared_buffers=512MB" "-c" "wal_compression=on"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready --dbname=\"\${POSTGRES_DB}\" --username=\"\${POSTGRES_USER}\" || exit 1; Chksum=\"$(psql --dbname=\"\${POSTGRES_DB}\" --username=\"\${POSTGRES_USER}\" --tuples-only --no-align --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')\"; echo \"checksum failure count is $Chksum\"; [ \"$Chksum\" = '0' ] || exit 1"
      "--health-interval=5m0s"
      "--health-start-interval=30s"
      "--health-start-period=5m0s"
      "--network-alias=database"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_redis" = {
    image = "docker.io/redis:6.2-alpine@sha256:eaba718fecd1196d88533de7ba49bf903ad33664a92debb24660a922ecd9cac8";
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping || exit 1"
      "--network-alias=redis"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_server" = {
    image = uptix.dockerImage "ghcr.io/immich-app/immich-server:release";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "${serviceOpts.dockerDir}/immich/db";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "release";
      "UPLOAD_LOCATION" = "/mnt/docker/photos/immich";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/mnt/docker/photos/immich:/usr/src/app/upload:rw"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/immich/env-app"
    ];
    ports = [
      "2283:2283/tcp"
    ];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-server"
      "--network=immich_default"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-immich_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-immich_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f immich_default";
    };
    script = ''
      docker network inspect immich_default || docker network create immich_default
    '';
    partOf = ["docker-compose-immich-root.target"];
    wantedBy = ["docker-compose-immich-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-immich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
