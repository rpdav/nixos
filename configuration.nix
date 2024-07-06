# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, secrets, ... }:

{
  imports =
    [ ./hardware-configuration.nix 
      ./cinnamon.nix
      ./rollback.nix
      #./gnome.nix
      #./kde.nix
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
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
    initrd.luks.devices = {
      enc = {
        device = "/dev/disk/by-uuid/9987f6a6-9368-41db-9815-176c57bf8cfa"; #this is the UUID of the boot partition
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

## Persistence
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
    adjtime.source = "/persist/etc/adjtime";
  };

  environment.persistence."/persist" = {
    enable = true;  # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/log"
#      "${secrets.test.alias}"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
#      "/etc/.updated" #systemd file with timestamp for when it was updated
#      "/var/.updated" #systemd file with timestamp for when it was updated
#      "/var/lib/sddm" # something to do with KDE
    ];
    files = [
       "/etc/machine-id"
       { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
    ## User persistence is here since I couldn't get it to work in home-manager
    users.ryan = {
      directories = [
        ".config"
        "Desktop"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        ".gnupg"
        ".ssh"
        ".nixops"
        ".local"
        ".mozilla"
        ".thunderbird"
        "scripts"
#        {
#          directory = ".local/share/Steam";
#          method = "symlink";
#        };
      ];
      files = [
        ".Xauthority"
      ];
    };
  };

## This should not be changed unless doing a fresh install
  system.stateVersion = "24.05"; # Did you read the comment?

}

