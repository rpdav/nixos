{
  lib,
  pkgs,
  configLib,
  inputs,
  config,
  ...
}:
#TODO add system stats here
let
  inherit (config.systemOpts) persistVol impermanent;
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
        #"system/common/optional/docker.nix" # container admin tools, not just for running containers
        #"system/common/optional/duplicati.nix"
        "system/common/optional/persistence"
        #"system/common/optional/wm/hyprland.nix"
        #"system/common/optional/yubikey.nix"

        # users
        "system/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    screenDimTimeout = 600;
    lockTimeout = 630;
    screenOffTimeout = 800;
    suspendTimeout = 900;
    diskDevice = "vda";
    swapSize = "8G";
    impermanent = true;
    gui = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  # Boot config
  boot = {
    loader = {
      systemd-boot = {
        enable = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "zenbook";
  networking.networkmanager = {
    enable = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    blueman
    qdirstat
    zoom-us
  ];

  # Create impermanent directories
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      #"/var/lib/iwd"
      "/etc/secureboot"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Server for gnome calendar
  services.gnome.evolution-data-server.enable = true;

  # minimal root user config
  users.users.root = {
    password = "changeme"; # Temporary password for initial reinstall; gets overridden by hashedPasswordFile when rebuilt with secrets
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
  };
}
