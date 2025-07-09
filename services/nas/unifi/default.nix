{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "unifi-config" = {
      target = "${dockerDir}/unifi-network-application/config";
    };
    "unifi-db" = {
      target = "${dockerDir}/unifi-network-application/db";
      mode = "0755";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."unifi" = {
    container = "unifi-network-application";
    port = 8443;
    protocol = "https";
  };

  # pull secret env file
  sops.secrets."selfhosting/unifi-network-application/env".owner = config.users.users.${dockerUser}.name;
}
