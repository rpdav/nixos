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
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../../common/users/ryan/keys;
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
        "system/common/optional/persistence"
        "system/common/optional/wm/hyprland.nix"
        "system/common/optional/yubikey.nix"

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
    diskDevice = "/dev/vda";
    swapSize = "16G";
    impermanent = true;
    gui = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  # Boot config with luks
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # more readable boot menu on hidpi display
        consoleMode = "5";
        configurationLimit = 30;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "fw13";
  networking.networkmanager = {
    enable = true;
  };

  # Host-specific hardware config
  services.pipewire = {
    audio.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.libinput.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Disable fingerprint for login (causes gnome-keyring unlock to fail)
  security.pam.services.login.fprintAuth = false;

  # System packages
  environment.systemPackages = with pkgs; [
    qdirstat
  ];

  # Create impermanent directories
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      "/etc/secureboot"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key); #allow root ssh for troubleshooting
  };
}
