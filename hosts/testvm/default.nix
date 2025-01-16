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
        "hosts/common/disks/btrfs-imp.nix"

        # optional config
        "hosts/common/optional/persistence"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix"

        # services
	"services/common/swag"
        "services/testvm"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      ./zfs.nix
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

#  fileSystems."/mnt/tank" = {
#    device = "tank";
#    fsType = "zfs";
#  };

  #todo change to systemd?
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testvm";

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
