{
  modulesPath,
  lib,
  pkgs,
  configLib,
  config,
  ...
}: {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/disks/btrfs-imp.nix"
        "hosts/common/core/packages.nix"
        "hosts/common/core/sops.nix"
      ])
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemSettings.swapEnable = true;
  systemSettings.swapSize = "4G";
  # this changes from one reboot to next - check before deploying!
  systemSettings.diskDevice = "sdb";
  systemSettings.gcRetention = "7d";
  systemSettings.impermanent = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testbox";

  services.openssh.enable = true;

  users.mutableUsers = false;

  sops.secrets."ryan/passwordhash" = {};

  users.users.root = {
    # password below is "changeme" for testing
    hashedPassword = "$6$ZKA9wKFWI9uZDKeq$VVH8V1ppkzx9awRcAPJYamkg4YBxgVNIzNFEc8taEq0koSEoFFAoMFFVBks6hH5FnQ5fbNo0..hpDrhlr3b9M.";
    # hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
    ];
  };

  system.stateVersion = "25.05";
}
