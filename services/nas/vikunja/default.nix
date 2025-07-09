{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."vikunja" = {
    subdomain = "todo";
    port = 3456;
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/vikunja/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/vikunja/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/vikunja/db 0700 0911 0911"
    "Z ${serviceOpts.dockerDir}/vikunja/db - 0911 0911"
  ];

  # pull secret env file
  sops.secrets."selfhosting/vikunja/env-app".owner = config.users.users.${serviceOpts.dockerUser}.name;
  sops.secrets."selfhosting/vikunja/env-db".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
