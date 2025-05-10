{
  modulesPath,
  lib,
  config,
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
        "hosts/common/optional/backup"
        "hosts/common/optional/persistence"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix"
        "hosts/common/optional/ssh-unlock.nix"
        "hosts/common/optional/stylix.nix"
        "hosts/common/optional/steam.nix"
        "hosts/common/optional/wm/gnome.nix"

        # services
        "services/common"
        "services/nas"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./nvidia.nix
      ./hardware-configuration.nix
      ./zfs
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts.username = "ryan"; #primary user (not necessarily only user)
  systemOpts = {
    swapEnable = true;
    diskDevice = "nvme1n1";
    swapSize = "16G";
    gcRetention = "30d";
    impermanent = true;
    gui = true;
  };
  serviceOpts.dockerDir = "/mnt/docker/appdata";
  backupOpts = {
    localRepo = "/mnt/storage/backups/borg";
    remoteRepo = "/mnt/B2/borg";
    sourcePaths = [config.systemOpts.persistVol];
    excludeList = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "*/home/*/.git/**" #can be restored from repo
      "**/.local/share/libvirt" #root and user vm images
      "*/var/**"
    ];
  };
  # disable emergency mode from preventing system boot if there are mounting issues
  systemd.enableEmergencyMode = false;

  # Needed for zfs
  networking.hostId = "7e3de5fa";

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "nas";

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
