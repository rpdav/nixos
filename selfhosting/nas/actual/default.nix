{...}: {
  flake.serviceModules.actual = {config, ...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."actualserver" = {};

    # Create swag proxy configs
    virtualisation.oci-containers.proxyConf."actual" = {
      container = "actualserver";
      subdomain = "budget";
      port = 5006;
      protocol = "http";
    };
    virtualisation.oci-containers.proxyConf."actual-api" = {
      container = "actual-api";
      subdomain = "budget-api";
      port = 5007;
    };

    # pull secret files
    sops.secrets."selfhosting/actual-api/env".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
  };
}
