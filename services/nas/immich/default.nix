{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."immich" = {
    container = "immich_server";
    subdomain = "photos";
    port = 2283;
    protocol = "http";
  };
  # Create directories for appdata and photos
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/immich/db 0700 999 users"
    "Z ${serviceOpts.dockerDir}/immich/db - 999 users"
    "d ${serviceOpts.dockerDir}/immich/model-cache 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/immich/model-cache - ${serviceOpts.dockerUser} users"
    "d /mnt/docker/photos/immich 0755 ${serviceOpts.dockerUser} users"
    "Z /mnt/docker/photos/immich - ${serviceOpts.dockerUser} users"
  ];

  # pull secret env file
  sops.secrets = {
    "selfhosting/immich/env-app".owner = config.users.users.${serviceOpts.dockerUser}.name;
    "selfhosting/immich/env-db".owner = config.users.users.${serviceOpts.dockerUser}.name;
  };
}
