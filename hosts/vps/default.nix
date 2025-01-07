{
  modulesPath,
  lib,
  configLib,
  userOpts,
  pkgs,
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

  # Enable Linode LISH console
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  boot.loader.grub.forceInstall = true;

  # Allow time for LISH connection delay
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  # Linode does not use predictable network names
  networking.usePredictableInterfaceNames = false;


  networking.useDHCP = false; # Disable DHCP globally as we will not need it.
  # required for ssh?
  networking.interfaces.eth0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    # Recommended utils per Linode
    inetutils
    mtr
    sysstat
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
 # boot.loader.grub = {
 #   efiSupport = true;
 #   efiInstallAsRemovable = true;
 # };

  networking.hostName = "vps";

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
