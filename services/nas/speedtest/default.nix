{config, ...}: let
  inherit (config) serviceOpts;
in {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."speedtest" = {
    container = "speedtest-tracker";
    port = 80;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/speedtest-tracker/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/speedtest-tracker/config - ${serviceOpts.dockerUser} users"
  ];
}
