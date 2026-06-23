{...}: {
  flake.serviceModules.gitea = {...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."gitea" = {};

    # Create swag proxy config
    virtualisation.oci-containers.proxyConfs."gitea" = {
      subdomain = "git";
      port = 3000;
      protocol = "http";
    };
  };
}
