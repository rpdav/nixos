{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."gitea" = {
    container = "gitea";
    subdomain = "git";
    port = 3000;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/gitea/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/gitea/config - ${serviceOpts.dockerUser} users"
  ];
}
