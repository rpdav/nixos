{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."kuma" = {
    container = "uptime-kuma";
    subdomain = "up";
    port = 3001;
    protocol = "http";
  };

  # Create directories to mount
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/uptime-kuma/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/uptime-kuma/config - ${serviceOpts.dockerUser} users"
  ];
}
