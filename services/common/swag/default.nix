{config, ...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."swag" = {};

  # Secrets
  sops.secrets = {
    "selfhosting/swag/cloudflareToken".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
  };
}
