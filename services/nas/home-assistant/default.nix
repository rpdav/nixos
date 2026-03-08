{
  config,
  lib,
  ...
}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "home-assistant-config" = {
      target = "${dockerDir}/Home-Assistant-Core/config";
    };
    "home-assistant-db" = {
      target = "${dockerDir}/Home-Assistant-Core/db";
    };
    "home-assistant-zwave" = {
      target = "${dockerDir}/Home-Assistant-Core/zwave";
    };
    "home-assistant-esp" = {
      target = "${dockerDir}/Home-Assistant-Core/esphome";
      mode = "777";
    };
  };

  # Create swag proxy configs
  virtualisation.oci-containers.proxy-conf."home-assistant" = {
    container = "home-assistant-app";
    subdomain = "home";
    port = 8123;
    protocol = "http";
  };
  virtualisation.oci-containers.proxy-conf."zwave" = {
    container = "home-assistant-zwave";
    subdomain = "zwave";
    port = 8091;
    protocol = "http";
  };
  virtualisation.oci-containers.proxy-conf."esphome" = {
    container = "nas.localdomain";
    subdomain = "esp";
    port = 6052;
    protocol = "http";
  };

  services.esphome = {
    enable = true;
    openFirewall = true;
    address = "0.0.0.0";
    #usePing = true;
  };
  services.avahi.enable = true;

  # Override persistent storage location for esphome service
  systemd.services.esphome = let
    cfg = config.services.esphome;
    stateDir = "${dockerDir}/Home-Assistant-Core/esphome";
    esphomeParams =
      if cfg.enableUnixSocket
      then "--socket /run/esphome/esphome.sock"
      else "--address ${cfg.address} --port ${toString cfg.port}";
    inherit (lib) mkForce;
  in {
    environment = {
      # platformio fails to determine the home directory when using DynamicUser
      PLATFORMIO_CORE_DIR = mkForce "${stateDir}/.platformio";
    };
    serviceConfig = {
      ExecStart = mkForce "${cfg.package}/bin/esphome dashboard ${esphomeParams} ${stateDir}";
      WorkingDirectory = mkForce stateDir;
    };
  };

  # Secret env file
  sops.secrets."selfhosting/home-assistant/env".owner = config.users.users.${dockerUser}.name;
}
