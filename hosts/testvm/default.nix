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
        "hosts/common/core"
	#TODO move this back into core when done testing
	"hosts/common/core/packages.nix"
	"hosts/common/core/sshd.nix"
	"hosts/common/core/sops.nix"
	"hosts/common/core/tailscale.nix"

        "hosts/common/disks/btrfs-imp.nix"
	

	"hosts/common/optional/persistence"
	# enable this once user config is more built out
	#"hosts/common/optional/yubikey"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  systemSettings.swapEnable = false;
  systemSettings.diskDevice = "vda";
  systemSettings.gcRetention = "7d";
  systemSettings.impermanent = true;
  systemSettings.gui = false;

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
