{
  lib,
  pkgs,
  configLib,
  inputs,
  config,
  ...
}: let
  inherit (config.systemOpts) persistVol impermanent;
in {
  ## This file contains host-specific NixOS configuration for my minimal install host
  ## Will be rebuilt after install using a permanent host

  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # import custom options
        "vars"
        # disk config
        "system/common/disks/luks-lvm-imp.nix"
      ])
      # host-specific
      ./hardware-configuration.nix
    ];

  # Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
  };

  # Variable overrides
  systemOpts = {
    diskDevice = "/dev/vda";
    swapSize = "16G";
    impermanent = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  # Boot config with luks
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "testvm";
  networking.networkmanager = {
    enable = true;
  };

  # Timezone
  time.timeZone = "America/Indiana/Indianapolis";

  # System packages
  environment.systemPackages = with pkgs; [
    firefox
    git
    vim
    borgbackup
    tree
    sops
    ssh-to-age
  ];

  # Create ssh host keys to import into sops if they don't already exist in backup
  services.openssh = {
    enable = true;
    ports = [22];
    settings.PasswordAuthentication = true;
    hostKeys = [
      {
        comment = "server key";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  # minimal root and primary user configs
  users.users.root = {
    password = "changeme";
  };
  users.users.ryan = {
    password = "changeme";
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
