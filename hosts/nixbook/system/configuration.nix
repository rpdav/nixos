{ config, lib, pkgs, secrets, systemSettings, userSettings, ... }:

{
  imports =
    [ ./hardware/hardware-configuration.nix
      ./hardware/video.nix
      ./persistence/rollback.nix
      ./persistence/persist.nix
      ./app/defaultapps.nix
      ./app/games/steam.nix
      ./security/tailscale.nix
      ./services/backup.nix
      ./wm/kde.nix
      ../../../variables.nix
   ];

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
        useOSProber = true;
      };
    };
    initrd.luks.devices = {
      enc = {
                 ## UUID of the encrypted partition 
        device = "/dev/disk/by-uuid/fda2cb5e-6df8-4f9c-a56a-35898a496ad1";
        preLVM = true;
      };
    };
  };

## Networking
  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # needed for wireguard on kde?

## Time
  time.timeZone = "America/Indiana/Indianapolis";

  services.libinput.enable = true;

## Enable sound and bluetooth.
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

## User definitions
  users.users.ryan = {
    hashedPassword = "${secrets.ryan.passwordhash}";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  nixpkgs.config.allowUnfree = true;

## Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    git-crypt
    wireguard-tools
    borgbackup
    rclone
    qdirstat
    killall
  ];

}

