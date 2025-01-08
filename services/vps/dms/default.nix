{serviceOpts, ...}:
{
  imports = [./docker-compose.nix];

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/dms/config 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/dms/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/dms/mail-data 0755 5000 5000"
    "Z ${serviceOpts.dockerDir}/dms/mail-data - 5000 5000"
    "d ${serviceOpts.dockerDir}/dms/mail-state 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/dms/mail-state - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/dms/mail-logs 0755 113 root"
    "Z ${serviceOpts.dockerDir}/dms/mail-logs - 113 root"
  ];

}
