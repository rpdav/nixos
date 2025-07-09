{config, ...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."silverbullet" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."silverbullet" = {
    subdomain = "notes";
    port = 3000;
    protocol = "http";
  };

  # Secret env file
  sops.secrets."selfhosting/silverbullet/env".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
}
