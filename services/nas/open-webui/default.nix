{...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."open-webui" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."open-webui" = {
    subdomain = "ai";
    port = 8080;
    protocol = "http";
  };
}
