{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/borgserver/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/borgserver/config - ${serviceOpts.dockerUser} users"
  ];

}