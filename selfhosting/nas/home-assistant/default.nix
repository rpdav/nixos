{inputs, ...}: {
  flake.serviceModules.home-assistant = {
    config,
    lib,
    ...
  }: let
    inherit (config.serviceOpts) dockerDir dockerUser;
    inherit (config.systemOpts) persistVol impermanent;
  in {
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
    };

    # Open HA port since we're exposing ports and host mode instead of using container DNS
    networking.firewall.allowedTCPPorts = [
      8123
    ];

    # Create swag proxy configs
    virtualisation.oci-containers.proxyConfs."home-assistant" = {
      container = "10.10.1.17"; # use host IP since using host networking
      subdomain = "home";
      port = 8123;
      protocol = "http";
    };
    virtualisation.oci-containers.proxyConfs."zwave" = {
      container = "home-assistant-zwave";
      subdomain = "zwave";
      port = 8091;
      protocol = "http";
    };
    virtualisation.oci-containers.proxyConfs."esphome" = {
      container = "nas.${inputs.nix-secrets.selfhosting.domain}";
      subdomain = "esp";
      port = 6052;
      protocol = "http";
    };

    # ESPHome config
    services.esphome = {
      enable = true;
      openFirewall = true;
      address = "0.0.0.0";
    };
    services.avahi.enable = true; # required for ESPHome mDNS discovery

    # Persist ESPHome data
    environment.persistence.${persistVol} = lib.mkIf impermanent {
      directories = [
        {
          directory = "/var/lib/esphome";
          mode = "0700";
          user = "esphome";
          group = "esphome";
        }
      ];
    };

    # Define esphome service user and group; service fails without correct ownership state directory
    users.users.esphome = {
      isSystemUser = true;
      group = "esphome";
    };
    users.groups.esphome = {};

    # Secret env file
    sops.secrets."selfhosting/home-assistant/env".owner = config.users.users.${dockerUser}.name;
  };
}
