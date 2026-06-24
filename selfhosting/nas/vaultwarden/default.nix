{...}: {
  flake.serviceModules.vaultwarden = {...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."vaultwarden" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConfs."vaultwarden" = {
      subdomain = "vault";
      port = 80;
      protocol = "http";
    };
  };
}
