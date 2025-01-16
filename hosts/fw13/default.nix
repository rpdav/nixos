{
  lib,
  pkgs,
  configLib,
  inputs,
  systemOpts,
  config,
  ...
}:
#TODO add system stats here
{
  ## This file contains host-specific NixOS configuration

  imports =
    lib.flatten #the list below is a nested list. imports doesn't accept this, so must use lib.flatten
    
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/core"

        # disk config
        "hosts/common/disks/luks-lvm-imp.nix"

        # optional config
        "hosts/common/optional/localbackup.nix"
        "hosts/common/optional/persistence"
        "hosts/common/optional/steam.nix"
        "hosts/common/optional/stylix.nix"
        "hosts/common/optional/wm/gnome.nix"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix" #container admin tools, not just for running containers

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nixos-cli.nixosModules.nixos-cli
    ];

  # Variable overrides
  userOpts.username = "ryan"; #primary user (not necessarily only user)
  userOpts.term = "alacritty";
  systemOpts.diskDevice = "nvme0n1";
  systemOpts.swapSize = "16G";
  systemOpts.impermanent = true;
  systemOpts.gui = true;

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
    lanzaboote = {
      enable = true;
      pkiBundle = "${systemOpts.persistVol}/etc/secureboot";
    };
  };

  # Networking
  networking.hostName = "fw13";
  networking.networkmanager.enable = true;

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

  # Create impermanent directories
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "/etc/secureboot"
      "/var/lib/fprint" # fingerprint reader
      "/var/lib/bluetooth"
    ];
    files = [
    "/root/.ssh/known_hosts"
    ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Misc
  services.nixos-cli.enable = true;

  # pmail bridge must be configured imperatively using the cli tool.
  # State in ~/.config is persisted. Runs as a user service even though
  # it's in system config.
  services.protonmail-bridge = {
    enable = true;
    # make gnome keyring available to bridge in case I'm running KDE
    path = with pkgs; [pass gnome-keyring];
  };

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
  
}
