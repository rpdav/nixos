{...}: {
  flake.serviceModules.duplicati = {config, ...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."duplicati" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConfs."duplicati" = {
      subdomain = "backups";
      port = 8200;
      protocol = "http";
    };

    # pull secret env file
    sops.secrets."selfhosting/duplicati/env".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
  };
}
