{ config, lib, pkgs, pkgs-stable, inputs, systemSettings, userSettings, secrets, ... }:

{
  imports =
   [  ./hardware-configuration.nix
      ../../variables.nix
      ../common/core
      ../common/optional/nvidia.nix
#      ../common/optional/localbackup.nix
      ../common/optional/persistence
      ../common/optional/sops.nix
      ../common/optional/sshd.nix
      ../common/optional/steam.nix
#      ../common/optional/stylix.nix #temporarily deactivated - throwing plasma look-and-feel errors on rebuild
      ../common/optional/wireguard.nix
      ../common/optional/wm/kde.nix
#      ../common/optional/wm/cosmic.nix
   ];

## Variable overrides
  userSettings.theme = lib.mkForce "snowflake-blue";

## This should not be changed unless doing a fresh install
  system.stateVersion = "24.05"; # Did you read the comment?

## Enable flakes
  nix = {
    package = pkgs.nixFlakes;
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
                 ## UUID of the encrypted partition 
        device = "/dev/disk/by-uuid/b784e938-236e-4fde-b97a-ec4b23b4814a";
        preLVM = true;
      };
    };
  };

## Networking
  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # needed for wireguard on kde

## Time
  time.timeZone = "systemSettings.timezone";

## Host-specific hardware config
  services.pipewire.audio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

## Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userSettings.username} = import ./home.nix;
    sharedModules = with inputs; [ 
      plasma-manager.homeManagerModules.plasma-manager 
      impermanence.nixosModules.home-manager.impermanence
    ];
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit secrets;
      inherit inputs;
    };
  };

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

