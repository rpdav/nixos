{...}: {
  flake.serviceModules.flatnotes = {config, ...}: {

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts."flatnotes".target = "data"; # defaults to ${dockerDir}/flatnotes/config

    # Create swag proxy config
    virtualisation.oci-containers.proxyConf."flatnotes" = {
      container = "flatnotes";
      subdomain = "notes";
      port = 8080;
      protocol = "http";
    };

    # pull secret env file
    sops.secrets."selfhosting/flatnotes/env".owner = config.users.users.${config.serviceOpts.dockerUser}.name;
  };
}
