{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."searxng" = {
    container = "searxng-app";
    subdomain = "search";
    port = 8080;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/searxng/config 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/searxng/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/searxng/redis 0755 999 users"
    "Z ${serviceOpts.dockerDir}/searxng/redis - 999 users"
  ];
}
