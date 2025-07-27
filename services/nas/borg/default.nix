{config, ...}: {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "borg-keys" = {
      target = "${config.serviceOpts.dockerDir}/borg/sshkeys";
    };
    "borg-data" = {
      target = "/mnt/storage/backups/borg";
    };
  };
}
