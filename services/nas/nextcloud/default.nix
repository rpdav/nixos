{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "nextcloud" = {};
    "nextcloud-db" = {
      target = "${dockerDir}/nextcloud/db";
    };
    "nextcloud-data" = {
      target = "/mnt/docker/nextcloud";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."nextcloud" = {
    subdomain = "cloud";
    port = 443;
    protocol = "https";
  };

  # Secret env file
  sops.secrets."selfhosting/nextcloud/env".owner = config.users.users.${dockerUser}.name;
}
