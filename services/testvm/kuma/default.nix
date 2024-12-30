{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create directories to mount
  systemd.tmpfiles.rules = [
    # config directory
    "d ${serviceOpts.dockerDir}/uptime-kuma/config 0700 ${serviceOpts.dockerUser} users"
    # swag reverse proxy config
    "f+ ${serviceOpts.dockerDir}/swag/proxy-confs/uptime-kuma.subdomain.conf 0700 ${serviceOpts.dockerUser} users - line1\\nline2 removed line3"
    ];
}
