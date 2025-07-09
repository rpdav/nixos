{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."unifi" = {
    container = "unifi-network-application";
    subdomain = "unifi";
    port = 8443;
    protocol = "https";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/unifi-network-application/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/unifi-network-application/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/unifi-network-application/db 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/unifi-network-application/db - ${serviceOpts.dockerUser} users"
  ];

  # pull secret env file
  sops.secrets."selfhosting/unifi-network-application/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
