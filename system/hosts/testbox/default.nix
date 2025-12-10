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
        "system/common/disks/btrfs-imp.nix"
        "system/common/core"
        #TODO move this back into core when done testing
        "system/common/core/packages.nix"
        "system/common/core/sshd.nix"
        "system/common/core/sops.nix"

        "system/common/optional/persistence"
      ])
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemOpts.swapEnable = true;
  systemOpts.swapSize = "4G";
  # this changes from one reboot to next - check before deploying!
  systemOpts.diskDevice = "sdb";
  systemOpts.gcRetention = "7d";
  systemOpts.impermanent = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testbox";

  #services.openssh.enable = true;

  users.mutableUsers = false;

  sops.secrets."passwordHashRyan".neededForUsers = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
    # password below is changeme for testing
    hashedPassword = "$6$Mz17vB64XrO4mfoR$tUW5V43Q4l9CL2EeAEy5qf9BhZv0aWojXufoCI2yaZ./3jTRKtHvgvJqWgC9g6Rl45iTtNn/9osJ.Mmgso2wa0";
    openssh.authorizedKeys.keys = [
      # yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
      # root's key - may not be needed if sudo isn't used for nixos-rebuild
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUY7K0mg1nTRf1gUloXdkX9QdMqXjzvszFDKYpFtekl root@borg"
    ];
  };

  system.stateVersion = "25.05";
}
