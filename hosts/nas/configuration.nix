{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.nas = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-nas];
  };
  flake.nixosModules.system-nas = {
    lib,
    pkgs,
    config,
    ...
  }:
  ## This file contains host-specific NixOS configuration for host nas
  ## CPU: AMD Ryzen 7 5700X3D 8-core
  ## GPU: Intel B580 12 GB
  ## RAM: 32 GB
  let
    inherit (config.systemOpts) persistVol impermanent;
  in {
    imports = [
      # core config
      self.nixosModules.core

      # optional config
      self.nixosModules.vim
      self.nixosModules.backupLocal
      self.nixosModules.backupRemote
      self.nixosModules.docker
      self.nixosModules.sshUnlock
      self.nixosModules.virtualization
      self.nixosModules.yubikey

      # users
      self.nixosModules.user-ryan

      # disk config
      self.diskoConfigurations.luks-lvm-imp

      # host-specific
      self.modules.nixos.rgb

      # self-hosted services
      self.serviceModules.swag
      self.serviceModules.beszelAgent
      self.serviceModules.actual
      self.serviceModules.albyhub
      self.serviceModules.beszel-hub
      self.serviceModules.borg
      self.serviceModules.duplicati
      self.serviceModules.flatnotes
      self.serviceModules.gitea
      self.serviceModules.guacamole
      self.serviceModules.heimdall
      self.serviceModules.home-assistant
      self.serviceModules.immich
      self.serviceModules.jellyfin
      self.serviceModules.lubelogger
      self.serviceModules.nextcloud
      self.serviceModules.planka
      self.serviceModules.searxng
      self.serviceModules.speedtest
      self.serviceModules.sunshine
      self.serviceModules.unifi
      self.serviceModules.vaultwarden
    ];

    # Variable overrides
    systemOpts = {
      primaryUser = "ryan"; # primary user (not necessarily only user)
      swapEnable = true;
      diskDevice = "nvme0n1";
      swapSize = "16G";
      gcRetention = "30d";
      impermanent = true;
      gui = false;
    };
    serviceOpts = {
      dockerDir = "/mnt/docker/appdata";
      proxyDir = "/run/selfhosting/proxyConfs";
    };

    # Packages
    environment.systemPackages = with pkgs; [
      openrgb-with-all-plugins
    ];
    # Backup config
    backupOpts = {
      localRepo = "ssh://borg@borg:2222/backup";
      remoteRepo = "/mnt/B2/borg";
      paths = [
        "${persistVol}/etc"
      ];
      patterns = [
        # Run `borg help patterns` for guidance on exclusion patterns
        "- */home/*/.git/**" # can be restored from repo
        "- **/.local/share/libvirt" # root and user vm images
        "- */var/**"
      ];
    };

    # Create impermanent directories
    environment.persistence.${persistVol} = lib.mkIf impermanent {
      directories = [
      ];
    };

    # disable emergency mode from preventing system boot if there are mounting issues
    systemd.enableEmergencyMode = false;

    # Networking
    networking = {
      hostId = "7e3de5fa"; # needed for zfs
      hostName = "nas";
    };

    # Boot
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
        };
        efi.canTouchEfiVariables = true;
      };
    };

    # RGB control
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
      server.port = 6742;
      autostart = {
        enable = true;
        mode = "color shift";
      };
    };

    # allow root ssh login for rebuilds
    users.users.root = {
      openssh.authorizedKeys.keyFiles = config.users.users.ryan.openssh.authorizedKeys.keyFiles;
    };
  };
}
