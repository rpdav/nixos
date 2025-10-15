{...}: {
  # Unlock secondary drives
  boot.initrd.luks.devices = {
    storage1.device = "/dev/disk/by-uuid/d364a03e-44cc-4b76-b088-a1ac234672f2"; # 4TB WD Red HDD
    storage2.device = "/dev/disk/by-uuid/766a4cfb-0d4a-4a1e-8e26-e6e35adf5d51"; # 4TB WD Red HDD
    docker1.device = "/dev/disk/by-uuid/8c643622-6836-4752-9d99-df8b977ddeca"; # 250 GB TEAM SATA SSD
    docker2.device = "/dev/disk/by-uuid/21a20fd8-9bdd-4332-8cdd-30df985ebac4"; # 250 GB TEAM SATA SSD
    # vms.device = "/dev/disk/by-uuid/a1570b31-323c-44b1-aadb-9fffcd1febe6"; # 1 TB WD black NVME SSD
  };

  # import zpools
  # at least one fileSystems parameter must be set, otherwise, boot.zfs.extraPools will not be imported
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
}
