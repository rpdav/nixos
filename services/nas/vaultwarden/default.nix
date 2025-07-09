{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."vaultwarden" = {
    subdomain = "vault";
    port = 80;
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/vaultwarden/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/vaultwarden/config - ${serviceOpts.dockerUser} users"
  ];
}
