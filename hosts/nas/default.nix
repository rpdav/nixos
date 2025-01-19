{
  modulesPath,
  lib,
  configLib,
  userOpts,
  ...
}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/${userOpts.username}/keys;
in {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/core"

        # disk config
        "hosts/common/disks/luks-lvm-imp.nix"

        # optional config
        "hosts/common/optional/persistence"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix"

        # services
        "services/common"
        "services/nas"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts.username = "ryan"; #primary user (not necessarily only user)
  systemOpts.swapEnable = true;
  systemOpts.diskDevice = "nvme1n1";
  systemOpts.swapSize = "16G";
  systemOpts.gcRetention = "30d";
  systemOpts.impermanent = true;
  systemOpts.gui = false;

  # disable emergency mode from preventing system boot if there are mounting issues
  systemd.enableEmergencyMode = false;

  # Needed for zfs
  networking.hostId = "7e3de5fa";

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Unlock secondary drives
  boot.initrd.luks.devices = {
    storage1.device = "/dev/disk/by-uuid/d364a03e-44cc-4b76-b088-a1ac234672f2"; # 4TB WD Red HDD
    storage2.device = "/dev/disk/by-uuid/766a4cfb-0d4a-4a1e-8e26-e6e35adf5d51"; # 4TB WD Red HDD
    docker1.device = "/dev/disk/by-uuid/8c643622-6836-4752-9d99-df8b977ddeca"; # 250 GB TEAM SATA SSD
    docker2.device = "/dev/disk/by-uuid/21a20fd8-9bdd-4332-8cdd-30df985ebac4"; # 250 GB TEAM SATA SSD
    vms.device = "/dev/disk/by-uuid/a1570b31-323c-44b1-aadb-9fffcd1febe6"; # 1 TB WD black NVME SSD
  };

  # import zpools
  fileSystems = {
    "/mnt/storage" = {
      device = "storage";
      fsType = "zfs";
    };
    "/mnt/docker" = {
      device = "docker";
      fsType = "zfs";
    };
    "/mnt/vms" = {
      device = "vms";
      fsType = "zfs";
    };
  };

  networking.hostName = "nas";

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
