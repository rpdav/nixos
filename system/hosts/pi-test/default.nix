# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  lib,
  pkgs,
  config,
  configLib,
  inputs,
  nixos-raspberrypi,
  ...
}:
## This file contains host-specific NixOS configuration for host pi-test
## CPU: Cortex-A72 4-core
## GPU: Broadcom VideoCore VI
## RAM: 2 GB
let
  inherit (config.systemOpts) persistVol impermanent;
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../../common/users/ryan/keys;
in {
  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # core config
      "system/common/core"

      # disk config
      #"system/common/disks/luks-lvm-imp.nix"

      # optional config
      "system/common/optional/wm/retroarch.nix"
      #"system/common/optional/backup"
      #"system/common/optional/docker.nix"
      #"system/common/optional/ssh-unlock.nix"
      "system/common/optional/wifi.nix"
      "system/common/optional/yubikey.nix"

      # users
      "system/common/users/ryan"
    ])

    # host-specific
    ./hardware-configuration.nix
    #./disk-ext4.nix
    nixos-raspberrypi.nixosModules.raspberry-pi-4.bluetooth
    nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    ## include these when using vanilla nixpkgs.lib.nixosSystem builder:
    nixos-raspberrypi.lib.inject-overlays
    nixos-raspberrypi.nixosModules.nixpkgs-rpi
    #nixos-raspberrypi.lib.inject-overlays-global # may cause lots of rebuilds
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
  userOpts.theme = lib.mkForce "retroarch";

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

  environment.systemPackages = with pkgs; [
    neovim
  ];

  # Networking
  networking = {
    hostName = "pi-test"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Boot
  boot.loader = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    generic-extlinux-compatible.enable = true;
  };

  # Don't use linux-rpi kernel from nixos-raspberrypi
  # Pull from nixpkgs cache instead. Otherwise, kernel will be compiled
  boot.kernelPackages = pkgs.linuxPackages;

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # RPi-specific Hardware config
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
