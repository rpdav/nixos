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
	"hosts/common/core/tailscale.nix"

	"hosts/common/optional/persistence"
	"hosts/common/optional/stylix.nix"
      ])
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemSettings.swapEnable = false;
  systemSettings.diskDevice = "vda";
  systemSettings.gcRetention = "7d";
  systemSettings.impermanent = true;
  systemSettings.gui = false;

#TODO move this to user definitions once set up
  userSettings.wallpaper = "none";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testvm";

  users.mutableUsers = false;

  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    openssh.authorizedKeys.keys = [
      # yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
    ];
  };

  system.stateVersion = "25.05";
}
