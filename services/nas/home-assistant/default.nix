{config, ...}: let
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
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."home-assistant" = {
    container = "home-assistant-app";
    subdomain = "home";
    port = 8123;
    protocol = "http";
  };

  # Secret env file
  sops.secrets."selfhosting/home-assistant/env".owner = config.users.users.${dockerUser}.name;
}
