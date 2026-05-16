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
        "system/common/core"

        # disk config
        "system/common/disks/luks-lvm-imp.nix"

        # optional config
        "system/common/optional/backup"
        "system/common/optional/docker.nix" # container admin tools, not just for running containers
        "system/common/optional/duplicati.nix"
        "system/common/optional/persistence"
        "system/common/optional/steam.nix"
        "system/common/optional/virtualization"
        "system/common/optional/wine.nix"
        "system/common/optional/wm/hyprland.nix"
        "system/common/optional/yubikey.nix"

        # users
        "system/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    screenDimTimeout = 600;
    lockTimeout = 630;
    screenOffTimeout = 800;
    suspendTimeout = 900;
    diskDevice = "sda";
    swapSize = "16G";
    impermanent = true;
    gui = true;
  };

  # Backup config
  backupOpts = {
    localRepo = "ssh://borg@borg:2222/backup";
    remoteRepo = "/mnt/B2/borg";
    paths = [
      "${persistVol}/etc"
    ];
    patterns = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "- */var/**" #not needed for restore
      "- **/.Trash*" #automatically made by gui deletions
      "- **/libvirt" #vdisks made mostly for testing
    ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  # Boot config with luks
  boot = {
    loader = {
      systemd-boot = {
        enable = false;
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
    blueman
    qdirstat
  ];

  # Create impermanent directories
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      #"/var/lib/iwd"
      "/etc/secureboot"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
  };
}
