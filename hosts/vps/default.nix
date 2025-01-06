{
  modulesPath,
  lib,
  configLib,
  userOpts,
  ...
}: let
  # Generates a list of the keys in ./keys
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
        "services/vps"

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
  systemOpts.swapSize= "2G";
  systemOpts.diskDevice = "sda";
  systemOpts.gcRetention = "7d";
  systemOpts.impermanent = true;
  systemOpts.gui = false;

  #todo change to systemd?
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "vps";

  # custom ssh port
  services.openssh.ports = lib.mkForce [44422];

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
