{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."silverbullet" = {
    container = "silverbullet";
    subdomain = "notes";
    port = 3000;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/silverbullet/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/silverbullet/config - ${serviceOpts.dockerUser} users"
  ];

  # Secret env file
  sops.secrets."selfhosting/silverbullet/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
