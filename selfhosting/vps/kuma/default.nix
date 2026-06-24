{...}: {
  flake.serviceModules.kuma = {...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."uptime-kuma" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConfs."kuma" = {
      container = "uptime-kuma";
      subdomain = "up";
      port = 3001;
      protocol = "http";
    };
  };
}
