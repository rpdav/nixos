{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.testvm = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.testvmSystem];
  };
  flake.nixosModules.testvmSystem = {
    lib,
    pkgs,
    config,
    ...
  }:
  #TODO add system stats here
  let
    inherit (config.systemOpts) persistVol impermanent;
  in {
    ## This file contains host-specific NixOS configuration

    imports = [
      # core config
      self.nixosModules.core

      # optional
      self.nixosModules.vim
      self.nixosModules.hyprland
      self.nixosModules.yubikeyConfig

      # users
      self.nixosModules.userRyan

      # disk config
      self.diskoConfigurations.luks-lvm-imp
    ];

    # Variable overrides
    systemOpts = {
      primaryUser = "ryan"; #primary user (not necessarily only user)
      screenDimTimeout = 600;
      lockTimeout = 630;
      screenOffTimeout = 800;
      suspendTimeout = 900;
      diskDevice = "/dev/vda";
      swapEnable = true;
      swapSize = "16G";
      impermanent = true;
      gui = true;
    };

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
    networking.hostName = "testvm";
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
      openssh.authorizedKeys.keyFiles = config.users.users.ryan.openssh.authorizedKeys.keyFiles;
    };
  };
}
