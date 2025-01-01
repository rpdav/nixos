{
  config,
  serviceOpts,
  ...
}: {
  imports = [./docker-compose.nix];

  # Secrets
  sops.secrets."selfhosting/testvm/cloudflareToken".owner = config.users.users.${serviceOpts.dockerUser}.name;

  # Create directories to mount
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/swag/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/swag/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/swag/proxy-confs 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/swag/proxy-confs - ${serviceOpts.dockerUser} users"
  ];
}
