{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.retropi = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-retropi];
  };
  flake.nixosModules.system-retropi = {
    lib,
    pkgs,
    config,
    ...
  }:
  ## This file contains host-specific NixOS configuration for host retropi
  ## CPU: Cortex-A72 4-core
  ## GPU: Broadcom VideoCore VI
  ## RAM: 2 GB
  {
    imports = [
      # core config
      self.nixosModules.core

      # optional
      self.nixosModules.vim
      self.nixosModules.retroarch
      self.nixosModules.backupLocal
      self.nixosModules.backupRemote
      self.nixosModules.wifi
      self.nixosModules.yubikeyConfig

      #users
      self.nixosModules.user-ryan
      self.nixosModules.user-retro

      # self-hosted services
      self.serviceModules.beszelAgent
    ];

    # Variable overrides
    systemOpts = {
      primaryUser = "retro"; # primary user (not necessarily only user)
      gcRetention = "30d";
      impermanent = false;
      gui = false;
    };

    userOpts.theme = lib.mkForce "retroarch";

    # Backup config
    backupOpts = {
      localRepo = "ssh://borg@borg:2222/backup";
      remoteRepo = "/mnt/B2/borg";
      paths = [
        "/etc"
        "/home"
      ];
      patterns = [
      ];
    };

    # Networking
    networking = {
      hostName = "retropi"; # Define your hostname.
      networkmanager.enable = true;
    };

    # Boot
    boot.loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };

    # allow root ssh login for rebuilds
    users.users.root = {
      openssh.authorizedKeys.keyFiles = config.users.users.ryan.openssh.authorizedKeys.keyFiles;
    };

    # RPi-specific Hardware config
    hardware.graphics.enable = true;
    hardware.bluetooth.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    ### Fix wifi not connecting due to broadcom bug
    networking.localCommands = ''
      ${pkgs.iw}/bin/iw reg set US
    '';
    boot.extraModprobeConfig = ''
      # Disable OBSS scanning feature which triggers chanspec -52 failure
      options brcmfmac feature_disable=0x200000
    '';
    networking.networkmanager = {
      wifi.scanRandMacAddress = false; # Disables randomization during background scans
    };
  };
}
