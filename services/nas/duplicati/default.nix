{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."duplicati" = {
    subdomain = "backups";
    port = 8200;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/duplicati/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/duplicati/config - ${serviceOpts.dockerUser} users"
  ];

  # pull secret env file
  sops.secrets."selfhosting/duplicati/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
