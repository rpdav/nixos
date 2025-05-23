# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  systemOpts,
  serviceOpts,
  uptix,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."home-assistant-app" = {
    image = uptix.dockerImage "homeassistant/home-assistant";
    volumes = [
      "${serviceOpts.dockerDir}/Home-Assistant-Core/config:/config:rw"
    ];
    ports = [
      "8123:8123/tcp"
    ];
    dependsOn = [
      "home-assistant-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=home-assistant"
      "--network=home-assistant_default"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-home-assistant-app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-home-assistant_default.service"
    ];
    requires = [
      "docker-network-home-assistant_default.service"
    ];
    partOf = [
      "docker-compose-home-assistant-root.target"
    ];
    wantedBy = [
      "docker-compose-home-assistant-root.target"
    ];
  };
  virtualisation.oci-containers.containers."home-assistant-db" = {
    image = uptix.dockerImage "lscr.io/linuxserver/mariadb";
    environment = {
      "PGID" = "1000";
      "PUID" = "1000";
      "TZ" = "${systemOpts.timezone}";
    };
    volumes = [
      "${serviceOpts.dockerDir}/Home-Assistant-Core/db:/config:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=home-assistant_default"
    ];
    environmentFiles = [
      "/run/secrets/selfhosting/home-assistant/env" # contains mysql password
    ];
  };
  systemd.services."docker-home-assistant-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-home-assistant_default.service"
    ];
    requires = [
      "docker-network-home-assistant_default.service"
    ];
    partOf = [
      "docker-compose-home-assistant-root.target"
    ];
    wantedBy = [
      "docker-compose-home-assistant-root.target"
    ];
  };
  virtualisation.oci-containers.containers."home-assistant-zwave" = {
    image = uptix.dockerImage "zwavejs/zwavejs2mqtt";
    environment = {
      "ZWAVEJS_EXTERNAL_CONFIG" = "/usr/src/app/store/.config-db";
    };
    volumes = [
      "${serviceOpts.dockerDir}/Home-Assistant-Core/zwave/data:/usr/src/app/store:rw"
      "${serviceOpts.dockerDir}/Home-Assistant-Core/zwave/log:/usr/src/app/bin:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave:rwm"
      "--network-alias=zwave"
      "--network=home-assistant_default"
      "--network=proxynet"
    ];
  };
  systemd.services."docker-home-assistant-zwave" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-home-assistant_default.service"
    ];
    requires = [
      "docker-network-home-assistant_default.service"
    ];
    partOf = [
      "docker-compose-home-assistant-root.target"
    ];
    wantedBy = [
      "docker-compose-home-assistant-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-home-assistant_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f home-assistant_default";
    };
    script = ''
      docker network inspect home-assistant_default || docker network create home-assistant_default
    '';
    partOf = ["docker-compose-home-assistant-root.target"];
    wantedBy = ["docker-compose-home-assistant-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-home-assistant-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
