{...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."heimdall" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."heimdall" = {
    subdomain = "start";
    port = 443;
    protocol = "https";
  };
}
