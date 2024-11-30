{ config, lib, pkgs, pkgs-stable, inputs, systemSettings, userSettings, secrets, configLib, ... }:
#TODO add system stats here

{
## This file contains host-specific NixOS configuration

  imports = lib.flatten #the list below is a nested list. imports doesn't accept this, so must use lib.flatten
   [  
     (map configLib.relativeToRoot [
       # core config
       "vars"
       "hosts/common/core"
       "hosts/common/disks/luks-lvm-imp.nix"

       # host-specific optional
       "hosts/common/optional/localbackup.nix"
       "hosts/common/optional/persistence"
       "hosts/common/optional/steam.nix"
       #"hosts/common/optional/stylix.nix" #temporarily deactivated - throwing plasma look-and-feel errors on rebuild
       "hosts/common/optional/wireguard.nix" #TODO replace vanilla wireguard with tailscale
       "hosts/common/optional/wm/gnome.nix"
       "hosts/common/optional/yubikey.nix"

       # users
       "hosts/common/users/ryan"
    ])

      # host-specific
      ./hardware-configuration.nix
   ];

  # Variable overrides
  userSettings.username = "ryan"; #primary user (not necessarily only user)
  systemSettings.diskDevice = "nvme0n1";
  systemSettings.swapSize = "16G";

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05"; 

  # Boot config with dual-boot and luks
  #TODO try replacing this with systemdboot
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "fw13nix";
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # needed for wireguard on kde

 # Host-specific hardware config
  services.pipewire.audio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    borgbackup
    qdirstat
  ];

  # Misc
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

}

