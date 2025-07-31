{...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."actualserver" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."actual" = {
    container = "actualserver";
    subdomain = "budget";
    port = 5006;
    protocol = "http";
  };
}
