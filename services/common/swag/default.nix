{inputs, ...}: {
  flake.serviceModules.swag = {config, ...}: {
    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."swag" = {};

    # Secrets
    sops.secrets."selfhosting/swag/cloudflareToken" = {
      owner = config.users.users.${config.serviceOpts.dockerUser}.name;
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      restartUnits = ["docker-swag.service"];
    };
  };
}
