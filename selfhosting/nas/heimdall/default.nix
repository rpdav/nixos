{...}: {
  flake.serviceModules.heimdall = {...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."heimdall" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConf."heimdall" = {
      subdomain = "start";
      port = 443;
      protocol = "https";
    };
  };
}
