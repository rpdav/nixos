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
      self.nixosModules.backup
      self.nixosModules.wifi
      self.nixosModules.yubikey

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
      paths = [
        "/etc"
        "/var/lib"
        "/home" # minimal user backup; just do it here instead of user backup
      ];
      patterns = [
        # Run `borg help patterns` for guidance on exclusion patterns
        "- */home/*/.git/**" # can be restored from repo
        "- */var/**"
      ];
    };

    # Services to monitor for failures
    services.failureNotify.units = [
      "borgmatic"
    ];

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

    services.tang = {
      enable = true;
      ipAddressAllow = ["10.10.1.0/24"];
    };

    # RPi-specific Hardware config
    hardware.graphics.enable = true;
    hardware.bluetooth.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Disable wifi when on lan
    networking.networkmanager.dispatcherScripts = [
      {
        source = pkgs.writeText "wifi-wired-exclusive" ''
          if [ "$1" = "end0" ]; then
            case "$2" in
              up)
                ${pkgs.networkmanager}/bin/nmcli radio wifi off
                ;;
              down)
                ${pkgs.networkmanager}/bin/nmcli radio wifi on
                ;;
            esac
          fi
        '';
        type = "basic";
      }
    ];
    # use same mac as lan so the same IP gets assigned whether on lan or wifi
    networking.networkmanager.wifi.macAddress = "e4:5f:01:0c:fa:b0";

    ### Fix wifi not connecting due to broadcom bug
    networking.localCommands = ''
      ${pkgs.iw}/bin/iw reg set US
    '';
    boot.extraModprobeConfig = ''
      # Disable OBSS scanning feature which triggers chanspec -52 failure
      options brcmfmac feature_disable=0x200000
    '';
    networking.networkmanager.wifi.scanRandMacAddress = false; # Disables randomization during background scans
  };
}
