{...}: {
  flake.serviceModules.lubelogger = {config, ...}: {

    virtualisation.oci-containers.mounts."lubelogger" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConf."lubelogger" = {
      container = "lubelogger";
      subdomain = "cars";
      port = 8080;
    };
  };
}
