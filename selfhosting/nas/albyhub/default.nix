{...}: {
  flake.serviceModules.albyhub = {...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."albyhub" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConf."albyhub" = {
      subdomain = "btc";
      port = 8080;
      protocol = "http";
    };
  };
}
