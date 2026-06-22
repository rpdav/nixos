{inputs, ...}: {
  flake.serviceModules.beszel-hub = {config, ...}: let
    inherit (config.serviceOpts) dockerDir;
  in {
    networking.firewall = {
      allowedTCPPorts = [8090];
    };

    # Enable service
    services.beszel.hub = {
      enable = true;
      host = "0.0.0.0";
      dataDir = "${dockerDir}/beszel-hub";
      environment = {
        APP_URL = "https://status.${inputs.nix-secrets.selfhosting.domain}";
        BASE_PATH = "/";
      };
    };

    # Define service user and group
    users = {
      users.beszel-hub = {
        isSystemUser = true;
        group = "beszel-hub";
      };
      groups.beszel-hub = {};
    };

    # Create/chmod appdata directories
    virtualisation.oci-containers.mounts = {
      "beszel-hub" = {
        target = "${dockerDir}/beszel-hub/beszel_data";
        user = "beszel-hub";
        mode = "0755";
      };
    };

    # Create swag proxy config
    virtualisation.oci-containers.proxyConf."beszel" = {
      container = "10.10.1.17";
      subdomain = "status";
      port = 8090;
      protocol = "http";
    };
  };
}
