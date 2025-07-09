{serviceOpts, ...}: {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."jellyfin" = {
    subdomain = "movies";
    port = 8096;
    protocol = "http";
  };
  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/jellyfin/library 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/jellyfin/library - ${serviceOpts.dockerUser} users"
    "d /mnt/storage/media/movies 0755 ${serviceOpts.dockerUser} users"
    "Z /mnt/storage/media/movies - ${serviceOpts.dockerUser} users"
    "d /mnt/storage/media/tvshows 0755 ${serviceOpts.dockerUser} users"
    "Z /mnt/storage/media/tvshows - ${serviceOpts.dockerUser} users"
  ];
}
