{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."nextcloud" = {
    container = "nextcloud";
    subdomain = "cloud";
    port = 443;
    protocol = "https";
  };
  # Create directories
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/nextcloud/config 0700 ${serviceOpts.dockerUser} users" # app config
    "Z ${serviceOpts.dockerDir}/nextcloud/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/nextcloud/db 0700 ${serviceOpts.dockerUser} users" # db config
    "Z ${serviceOpts.dockerDir}/nextcloud/db - ${serviceOpts.dockerUser} users"
    "d /mnt/docker/nextcloud 0700 ${serviceOpts.dockerUser} users" # app data
    "Z /mnt/docker/nextcloud - ${serviceOpts.dockerUser} users"
  ];

  # Secret env file
  sops.secrets."selfhosting/nextcloud/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
