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
  # Generates a list of the keys in admin user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
in {
  ## This file contains host-specific NixOS configuration

  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "system/common/core"

        # disk config
        "system/common/disks/luks-lvm-imp.nix"

        # optional config
        "system/common/optional/backup"
        "system/common/optional/duplicati.nix"
        "system/common/optional/persistence"
        "system/common/optional/wm/cinnamon.nix"

        # users
        "system/common/users/ryan"
        "system/common/users/ariel"
      ])

      # host-specific
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ariel"; #primary user (not necessarily only user)
    diskDevice = "nvme0n1";
    swapSize = "8G";
    impermanent = true;
    gui = true;
  };

  # Backup config
  backupOpts = {
    localRepo = "ssh://borg@borg:2222/backup";
    #remoteRepo = "/mnt/B2/borg";
    paths = [
      "${persistVol}/etc"
    ];
    patterns = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "- */var/**" #not needed for restore
      "- **/.Trash*" #automatically made by gui deletions
    ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";

  # bootloader
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Networking
  networking.hostName = "vivobook";
  networking.networkmanager.enable = true;

  # Host-specific hardware config
  services.pipewire = {
    audio.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    qdirstat
  ];

  # Create impermanent directories
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/bluetooth"
      # Entire user directories are persisted for this host
      {
        directory = "/home/ryan";
        user = "ryan";
        mode = "0700";
      }
      {
        directory = "/home/ariel";
        user = "ariel";
        mode = "0700";
      }
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
  };
}
