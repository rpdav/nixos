{ config, lib, pkgs, pkgs-stable, secrets, inputs, systemSettings, userSettings, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../../variables.nix
      ../../modules/nixos/hybridgpu.nix
      ../../modules/nixos/localbackup.nix
      ../../modules/nixos/persistence
      ../../modules/nixos/steam.nix
      ../../modules/nixos/tailscale.nix
      ../../modules/nixos/wm/kde.nix
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

## Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ryan = import ./home.nix;
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
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-stable; [
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
