{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "vikunja-config" = {
      target = "${dockerDir}/vikunja/config";
    };
    "vikunja-db" = {
      target = "${dockerDir}/vikunja/db";
      user = "0911";
      group = "0911";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."vikunja" = {
    subdomain = "todo";
    port = 3456;
    protocol = "http";
  };

  # pull secret env file
  sops.secrets."selfhosting/vikunja/env-app".owner = config.users.users.${dockerUser}.name;
  sops.secrets."selfhosting/vikunja/env-db".owner = config.users.users.${dockerUser}.name;
}
