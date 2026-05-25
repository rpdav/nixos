# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  pkgs,
  config,
  configLib,
  inputs,
  outputs,
  ...
}:
## This file contains host-specific NixOS configuration for host pi-test
## CPU: Cortex-A72 4-core
## GPU: Integrated
## RAM: 2 GB
let
  inherit (config.systemOpts) persistVol impermanent;
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../../common/users/ryan/keys;
in {
  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "vars"
      "system/common/core"

      # disk config
      #"system/common/disks/luks-lvm-imp.nix"

      # optional config
      #"system/common/optional/backup"
      #"system/common/optional/docker.nix"
      #"system/common/optional/ssh-unlock.nix"
      "system/common/optional/yubikey.nix"

      # users
      "system/common/users/ryan"
    ])

    # host-specific
    ./hardware-configuration.nix
    # nixos-hardware causes kernel to need to be compiled locally.
    # may be able to avoid this by setting boot.kernelPackages = pkgs.linuxPackages;
    # for now, just disabling
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; # primary user (not necessarily only user)
    swapEnable = true;
    diskDevice = "mmcblk0";
    swapSize = "2G";
    gcRetention = "30d";
    impermanent = false; # to be changed after enabling disko
    gui = false;
  };

  # Backup config
  backupOpts = {
    localRepo = "ssh://borg@borg:2222/backup";
    remoteRepo = "/mnt/B2/borg";
    paths = [
      "${persistVol}/etc"
    ];
    patterns = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "- */home/*/.git/**" # can be restored from repo
      "- */var/**"
    ];
  };

  # Create impermanent directories
  #environment.persistence.${persistVol} = lib.mkIf impermanent {
  #  directories = [
  #  ];
  #};

  # Networking
  networking = {
    hostName = "pi-test"; # Define your hostname.
    networkmanager.enable = true;
  };
  #TODO: add wifi config here?

  # Boot
  boot.loader = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    generic-extlinux-compatible.enable = true;
  };

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # RPi-specific Hardware config
  #hardware.raspberry-pi."4" = {
  #  audio.enable = true;
  #  bluetooth.enable = true;
  #};

  system.stateVersion = "26.05"; # Did you read the comment?
}
