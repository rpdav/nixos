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
        #"system/common/core"

        # disk config
        "system/common/disks/luks-lvm-imp.nix"

        # optional config
        #"system/common/optional/backup"
        #"system/common/optional/docker.nix" # container admin tools, not just for running containers
        #"system/common/optional/duplicati.nix"
        #"system/common/optional/persistence"
        #"system/common/optional/steam.nix"
        #"system/common/optional/virtualization"
        #"system/common/optional/wine.nix"
        #"system/common/optional/wm/hyprland.nix"
        #"system/common/optional/yubikey.nix"

        # users
        #"system/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    diskDevice = "vda";
    swapSize = "16G";
    impermanent = true;
    gui = false;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  # Boot config with luks
  boot = {
    loader = {
      systemd-boot = {
        enable = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "testvm";
  networking.networkmanager = {
    enable = true;
  };

  # Host-specific hardware config
  services.pipewire = {
    audio.enable = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;

  # minimal root user config
  users.users.root = {
    password = "changeme";
  };
  users.users.ryan = {
    isNormalUser = true;
    password = "changeme";
  };
}
