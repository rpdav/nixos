{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."serviceName" = {
    container = "containerName"; # defaults to serviceName if blank
    subdomain = "www"; # defaults to serviceName if blank
    port = 8080;
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/_CONTAINER_/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/_CONTAINER_/config - ${serviceOpts.dockerUser} users"
  ];

  # pull secret env file
  sops.secrets."selfhosting/_CONTAINER_/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
