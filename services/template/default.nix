{config, ...}: let
  inherit (config) serviceOpts;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  # Option 1: This will create a directory at ${dockerDir}/serviceName/config owned by ${dockerUser}:users with mode 0700
  virtualisation.oci-containers.mounts."containerName" = {};

  # Option 2: Define paths explicitly
  virtualisation.oci-containers.mounts."containerName" = {
    target = ""; # defaults to ${dockerDir}/containerName/config
    mode = ""; # default 0700
    user = ""; # default dockerUser
    group = ""; # default users
  };

  # Option 3: define multiple paths (one for app, one for db, etc)
  virtualisation.oci-containers.mounts = {
    "containerName-app" = {
      target = "${serviceOpts.dockerDir}/containerName/config";
    };
    "containerName-db" = {
      target = "${serviceOpts.dockerDir}/containerName/db";
      user = "999"; # databases often run as different users
      mode = "0755";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."serviceName" = {
    container = "containerName"; # defaults to serviceName if blank
    subdomain = "www"; # defaults to serviceName if blank
    port = 8080;
    protocol = "http";
  };

  # pull secret env file
  sops.secrets."selfhosting/containerName/env".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
}
