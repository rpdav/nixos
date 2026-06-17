{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
## This file contains host-specific NixOS configuration for host retropi
## CPU: Cortex-A72 4-core
## GPU: Broadcom VideoCore VI
## RAM: 2 GB
let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../../common/users/ryan/keys;
in {
  imports = lib.flatten [
    (map configLib.relativeToRoot [
      # optional config
      "system/common/optional/wm/retroarch.nix"
      "system/common/optional/backup"
      "system/common/optional/wifi.nix"
      "system/common/optional/yubikey.nix"
      "services/common/beszel-agent"

      # users
      "system/common/users/ryan"
      "system/common/users/retro"
    ])

    # host-specific
    ./hardware-configuration.nix
  ];

  # Variable overrides
  systemOpts = {
    primaryUser = "retro"; # primary user (not necessarily only user)
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
      "/etc"
      "/home"
    ];
    patterns = [
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim # nvf causes compilation; just using vanilla nvim for pi
  ];

  # Networking
  networking = {
    hostName = "retropi"; # Define your hostname.
    networkmanager.enable = true;
  };

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
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  ### Fix wifi not connecting due to broadcom bug
  networking.localCommands = ''
    ${pkgs.iw}/bin/iw reg set US
  '';
  boot.extraModprobeConfig = ''
    # Disable OBSS scanning feature which triggers chanspec -52 failure
    options brcmfmac feature_disable=0x200000
  '';
  networking.networkmanager = {
    wifi.scanRandMacAddress = false; # Disables randomization during background scans
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
