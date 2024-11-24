{ config, lib, pkgs, pkgs-stable, inputs, systemSettings, userSettings, secrets, configLib, ... }:

{
## This file contains host-specific NixOS configuration

  imports =
   [  ./hardware-configuration.nix
      (configLib.relativeToRoot "vars")
      ../common/core
      ../common/optional/nvidia.nix
      ../common/optional/localbackup.nix
      ../common/optional/persistence
      ../common/optional/steam.nix
#      ../common/optional/stylix.nix #temporarily deactivated - throwing plasma look-and-feel errors on rebuild
      ../common/optional/wireguard.nix #TODO replace vanilla wireguard with tailscale
      ../common/optional/wm/gnome.nix
      ../common/optional/yubikey.nix

      # users
      ../common/users/ryan
   ];

## Variable overrides
  userSettings.username = "ryan"; #primary user (not necessarily only user)

## https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05"; 

## Boot config with dual-boot and luks
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
      timeout = 2;
    };
    initrd.luks.devices = {
      crypt = {
        device = "/dev/disk/by-uuid/58d1a163-40f1-4aed-8f6f-cadf1b180e57"; ## UUID of the encrypted partition 
        preLVM = true;
      };
    };
  };

## Networking
  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # needed for wireguard on kde

## Host-specific hardware config
  services.pipewire.audio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

## System packages
  environment.systemPackages = with pkgs; [
    borgbackup
    qdirstat
  ];

## Misc
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

}

