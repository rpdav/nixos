# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, secrets, ... }:

{
  imports =
    [ ./hardware-configuration.nix 
      ./persistence/rollback.nix
      ./persistence/persist.nix
      ./security/wireguard.nix
      ./wm/cinnamon.nix
      #./wm/gnome.nix
      #./wm/kde.nix
    ];

## Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

# Copied from hadilq guide
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
        device = "/dev/disk/by-uuid/fda2cb5e-6df8-4f9c-a56a-35898a496ad1"; #this is the UUID of the encrypted partition 
        preLVM = true;
      };
    };
  };
  
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after reboot
    Defaults lecture = never
    '';
    
  networking.hostName = "nixbook";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Indiana/Indianapolis";

  services.libinput.enable = true;
  services.displayManager.defaultSession = "cinnamon";

  # Enable sound.
  hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

## This may be replaced by home manager block.
  users.users.ryan = {
    hashedPassword = "***REMOVED***";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  nixpkgs.config.allowUnfree = true;

## Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    git-crypt
  ];

## Default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "default-web-browser" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

## This should not be changed unless doing a fresh install
  system.stateVersion = "24.05"; # Did you read the comment?

}

