{...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."vaultwarden" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."vaultwarden" = {
    subdomain = "vault";
    port = 80;
    protocol = "http";
  };
}
