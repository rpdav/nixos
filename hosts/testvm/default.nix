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
        "services/testvm"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      #./zfs.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts.username = "ryan"; #primary user (not necessarily only user)
  systemOpts.swapEnable = false;
  systemOpts.diskDevice = "vda";
  systemOpts.gcRetention = "7d";
  systemOpts.impermanent = true;
  systemOpts.gui = false;

#  boot.zfs.extraPools = [ "tank" ]; # not needed if using filesystems block below

  # disable emergency mode from preventing system boot if there are mounting issues
  systemd.enableEmergencyMode = false;

  # Needed for zfs
  networking.hostId = "1d5aec24";


  #todo change to systemd?
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Unlock secondary drives
  boot.initrd.luks.devices = {
    zfs1.device = "/dev/disk/by-uuid/f90feb66-b8e9-4331-8d80-ebe0b56f6a52";
    zfs2.device = "/dev/disk/by-uuid/2f82d38e-a1e9-43bd-a9a2-c4b4c7fc23cc";
#    storage1.device = "/dev/disk/by-uuid/d364a03e-44cc-4b76-b088-a1ac234672f2"; # nas sdd 4TB drive
#    storage2.device = "/dev/disk/by-uuid/766a4cfb-0d4a-4a1e-8e26-e6e35adf5d51"; # nas sde 4%B drive
  };

  # import test zpool
  fileSystems."/mnt/tank" = {
    device = "tank";
    fsType = "zfs";
  };

  # import storage zpool
#  fileSystems."/mnt/storage" = {
#    device = "storage";
#    fsType = "zfs";
#  };

  # Boot config with luks
#  boot = {
#    loader = {
#      grub.device = "nodev";
#      systemd-boot = {
#        enable = false;
#        # more readable boot menu on hidpi display
#        consoleMode = "5";
#        configurationLimit = 30;
#      };
#      efi.canTouchEfiVariables = true;
#    };
#  };
  networking.hostName = "testvm";

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
