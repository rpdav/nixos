{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."alby" = {
    container = "albyhub";
    subdomain = "btc";
    port = 8080;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/albyhub/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/albyhub/config - ${serviceOpts.dockerUser} users"
  ];
}
