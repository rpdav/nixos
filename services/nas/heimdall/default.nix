{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."heimdall" = {
    subdomain = "start";
    port = 443;
    protocol = "https";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/heimdall/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/heimdall/config - ${serviceOpts.dockerUser} users"
  ];
}
