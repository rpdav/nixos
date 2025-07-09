{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
  plankaDir = "${dockerDir}/planka";
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "planka-favicons" = {
      target = "${plankaDir}/favicons";
    };
    "planka-user-avatars" = {
      target = "${plankaDir}/user-avatars";
    };
    "planka-background-images" = {
      target = "${plankaDir}/background-images";
    };
    "planka-attachments" = {
      target = "${plankaDir}/attachments";
    };
    "planka-db-data" = {
      target = "${plankaDir}/db-data";
      user = "70";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."planka" = {
    container = "planka-app";
    subdomain = "projects";
    port = 1337;
    protocol = "http";
  };
  # pull secret env file
  sops.secrets."selfhosting/planka/env".owner = config.users.users.${dockerUser}.name;
}
