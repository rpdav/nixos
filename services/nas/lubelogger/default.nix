{config, ...}: {
  imports = [./docker-compose.nix];

  virtualisation.oci-containers.mounts."lubelogger" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."lubelogger" = {
    container = "lubelogger";
    subdomain = "cars";
    port = 8080;
  };
}
