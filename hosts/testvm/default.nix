{
  modulesPath,
  lib,
  configLib,
  ...
}: {
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
	"services/testvm/swag"
	"services/testvm/kuma"
	"services/testvm/vaultwarden"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts.username = "ryan"; #primary user (not necessarily only user)
  systemOpts.swapEnable = false;
  systemOpts.diskDevice = "vda";
  systemOpts.gcRetention = "7d";
  systemOpts.impermanent = true;
  systemOpts.gui = false;

  #todo change to systemd?
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "testvm";

  # allow root ssh login for this host only
  #TODO this key is just hard-coded - any way to dynamically add keys like in
  #hosts/common/users?
  users.users.root = {
    openssh.authorizedKeys.keys = [
      # yubikey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
    ];
  };

  system.stateVersion = "25.05";
}
