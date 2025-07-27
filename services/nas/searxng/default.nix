{config, ...}: let
  inherit (config.serviceOpts) dockerDir;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "searxng-config" = {
      target = "${dockerDir}/searxng/config";
      mode = "0755";
    };
    "searxng-redis" = {
      target = "${dockerDir}/searxng/redis";
      user = "999";
      mode = "0755";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."searxng" = {
    container = "searxng-app";
    subdomain = "search";
    port = 8080;
    protocol = "http";
  };
}
