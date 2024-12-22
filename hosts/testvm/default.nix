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
	#TODO move this back into core when done testing
	"hosts/common/core/packages.nix"
	"hosts/common/core/sshd.nix"
	"hosts/common/core/sops.nix"

	"hosts/common/optional/persistence"
      ])
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemSettings.swapEnable = false;
  # this changes from one reboot to next - check before deploying!
  systemSettings.diskDevice = "vda";
  systemSettings.gcRetention = "7d";
  systemSettings.impermanent = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testvm";

  #services.openssh.enable = true;

  users.mutableUsers = false;

  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    # password below is changeme for testing
    hashedPassword = "$6$Mz17vB64XrO4mfoR$tUW5V43Q4l9CL2EeAEy5qf9BhZv0aWojXufoCI2yaZ./3jTRKtHvgvJqWgC9g6Rl45iTtNn/9osJ.Mmgso2wa0";
    openssh.authorizedKeys.keys = [
      # yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
    ];
  };

  system.stateVersion = "25.05";
}
