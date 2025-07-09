{
  serviceOpts,
  config,
  ...
}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."planka" = {
    container = "planka-app";
    subdomain = "projects";
    port = 1337;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/planka/favicons 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/favicons - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/user-avatars 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/user-avatars - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/background-images 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/background-images - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/attachments 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/attachments - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/db-data 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/db-data - 70 users"
  ];

  # pull secret env file
  sops.secrets."selfhosting/planka/env".owner = config.users.users.${serviceOpts.dockerUser}.name;
}
