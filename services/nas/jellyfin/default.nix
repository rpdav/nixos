{config, ...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "jellyfin-library" = {
      target = "${config.serviceOpts.dockerDir}/jellyfin/config";
    };
    "jellyfin-movies" = {
      target = "/mnt/storage/media/movies";
      mode = "0755";
    };
    "jellyfin-tvshows" = {
      target = "/mnt/storage/media/tvshows";
      mode = "0755";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."jellyfin" = {
    subdomain = "movies";
    port = 8096;
    protocol = "http";
  };
}
