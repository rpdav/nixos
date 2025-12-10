{
  lib,
  pkgs,
  configLib,
  inputs,
  config,
  ...
}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
  inherit (config) systemOpts;
in {
  ## This file contains host-specific NixOS configuration

  imports =
    lib.flatten #the list below is a nested list. imports doesn't accept this, so must use lib.flatten
    
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "system/common/core"

        # disk config
        "system/common/disks/luks-lvm-imp.nix"

        # optional config
        #"system/common/optional/backup"
        #"system/common/optional/duplicati.nix"
        "system/common/optional/persistence"
        "system/common/optional/stylix.nix"
        "system/common/optional/wm/cinnamon.nix"
        "system/common/optional/yubikey.nix"

        # users
        "system/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    diskDevice = "vda";
    swapSize = "6G";
    impermanent = true;
    gui = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Networking
  networking.hostName = "testvm";
  networking.networkmanager.enable = true;

  # Host-specific hardware config
  services.pipewire = {
    audio.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    qdirstat
  ];

  # Create impermanent directories
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "/var/lib/bluetooth"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
}
