{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "immich-db" = {
      target = "${dockerDir}/immich/db";
      user = "999";
    };
    "immich-model-cache" = {
      target = "${dockerDir}/immmich/model-cache";
      mode = "0755";
    };
    "immich-photos" = {
      target = "/mnt/docker/photos/immich";
      mode = "0755";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."immich" = {
    container = "immich_server";
    subdomain = "photos";
    port = 2283;
    protocol = "http";
  };

  # pull secret env file
  sops.secrets = {
    "selfhosting/immich/env-app".owner = config.users.users.${dockerUser}.name;
    "selfhosting/immich/env-db".owner = config.users.users.${dockerUser}.name;
  };
}
