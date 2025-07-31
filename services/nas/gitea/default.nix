{...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts."gitea" = {};

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."gitea" = {
    subdomain = "git";
    port = 3000;
    protocol = "http";
  };
}
