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
        "hosts/common/core"
	"hosts/common/optional/persistence"
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

  users.mutableUsers = false;

  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    openssh.authorizedKeys.keys = [
      # yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
      # root's key - may not be needed if sudo isn't used for nixos-rebuild
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUY7K0mg1nTRf1gUloXdkX9QdMqXjzvszFDKYpFtekl root@borg"
    ];
  };

  system.stateVersion = "25.05";
}
