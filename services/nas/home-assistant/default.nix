{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."home-assistant" = {
    container = "home-assistant-app";
    subdomain = "home";
    port = 8123;
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/db 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/db - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/zwave 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/zwave - ${serviceOpts.dockerUser} users"
  ];

  # Secret env file
  sops.secrets."selfhosting/home-assistant/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
