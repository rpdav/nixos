{ config, lib, pkgs, pkgs-stable, inputs, systemSettings, userSettings, secrets, ... }:

{
  imports =
   [  ./hardware-configuration.nix
      ../../variables.nix
      ../common/core
      ../common/optional/nvidia.nix
      ../common/optional/localbackup.nix
      ../common/optional/persistence
      ../common/optional/sops.nix
      ../common/optional/sshd.nix
      ../common/optional/steam.nix
#      ../common/optional/stylix.nix #temporarily deactivated - throwing plasma look-and-feel errors on rebuild
      ../common/optional/wireguard.nix
      ../common/optional/wm/kde.nix
#      ../common/optional/wm/cosmic.nix

      # users
      ../common/users/ryan
   ];

## Variable overrides
  userSettings.theme = lib.mkForce "snowflake-blue";

## https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05"; 

## Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


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

