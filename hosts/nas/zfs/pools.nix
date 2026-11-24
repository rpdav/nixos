{
  flake.nixosModules.system-nas = {
    config,
    lib,
    ...
  }: {
    # Unlock secondary drives
    sops.secrets.zfs-luks-key = {};
    environment.etc.crypttab.text = ''
      # 4TB WD Red HDD
      storage1 /dev/disk/by-uuid/d364a03e-44cc-4b76-b088-a1ac234672f2 ${config.sops.secrets.zfs-luks-key.path} luks 
      # 4TB WD Red HDD
      storage2 /dev/disk/by-uuid/766a4cfb-0d4a-4a1e-8e26-e6e35adf5d51 ${config.sops.secrets.zfs-luks-key.path} luks
      # 250 GB TEAM SATA SSD
      docker1  /dev/disk/by-uuid/8c643622-6836-4752-9d99-df8b977ddeca ${config.sops.secrets.zfs-luks-key.path} luks
      # 250 GB TEAM SATA SSD
      docker2  /dev/disk/by-uuid/21a20fd8-9bdd-4332-8cdd-30df985ebac4 ${config.sops.secrets.zfs-luks-key.path} luks
    '';

    # ZFS module adds network-online.target to these when
    # boot.clevis.useTang is enabled. This causes ordering
    # cycle issues. This removes that. Network isn't needed
    # for zfs since the keyfile is local.
    systemd.services = lib.genAttrs ["zfs-import-docker" "zfs-import-storage"] (_: {
      after = lib.mkForce [
        "systemd-modules-load.service"
        "systemd-ask-password-console.service"
      ];
      wants = lib.mkForce [];
    });

    boot.zfs.forceImportRoot = false;

    # import zpools
    # at least one fileSystems.<name> option must be set, otherwise, boot.zfs.extraPools will not be imported.
    # Filesystems mounted using fileSystems."/mount/point" will throw a boot error if the zfs mountpoint property
    # isn't set to legacy. But they will still eventually mount.
    fileSystems = {
      "/mnt/storage" = {
        device = "storage";
        fsType = "zfs";
      };
    };
    boot.zfs = {
      extraPools = [
        "docker"
      ];
    };
  };
}
