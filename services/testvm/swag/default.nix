{
  config,
  serviceOpts,
  ...
}: {
  imports = [./docker-compose.nix];

  sops.secrets."selfhosting/testvm/cloudflareToken" = {
    path = "${serviceOpts.dockerDir}/swag/secrets/cloudflareToken";
    owner = config.users.users.${serviceOpts.dockerUser}.name;
  };
}
