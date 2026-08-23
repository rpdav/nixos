{...}: {
  flake.serviceModules.borg = {config, ...}: {
    # decrypt server key
    sops.secrets."selfhosting/borg/ssh_server_key" = {};

    # Create/chmod appdata directories to mount
    virtualisation.oci-containers.mounts = {
      "borg-keys" = {
        target = "${config.serviceOpts.dockerDir}/borg/sshkeys";
      };
      "borg-data" = {
        target = "/mnt/storage/backups/borg";
      };
    };
  };
}
