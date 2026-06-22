{...}: {
  flake.serviceModules.sunshine = {config, ...}: {
    # No actual service here, just a reverse proxy for win10 vm
    # sunshine gamestream service

    virtualisation.oci-containers.proxyConf."sunshine" = {
      container = "10.10.1.20";
      subdomain = "sunshine";
      port = 47990;
    };
  };
}
