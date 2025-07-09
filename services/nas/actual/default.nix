{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."actual" = {
    container = "actualserver";
    subdomain = "budget";
    port = 5006;
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/actualserver/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/actualserver/config - ${serviceOpts.dockerUser} users"
  ];
}
