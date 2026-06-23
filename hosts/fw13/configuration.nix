{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.fw13 = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-fw13];
  };
  flake.nixosModules.system-fw13 = {
    lib,
    pkgs,
    config,
    ...
  }:
  ## This file contains host-specific NixOS configuration for host fw13
  ## CPU: AMD Ryzen 5 7640U 6-core
  ## GPU: AMD Radeon 760M integrated graphics
  ## RAM: 32 GB
  let
    inherit (config.systemOpts) persistVol impermanent;
  in {
    imports = with self.nixosModules;
      [
        # core config
        core

        # optional config
        admin
        vim
        backupLocal
        backupRemote
        docker
        duplicati
        plymouth
        games
        virtualization
        wifi
        yubikeyConfig

        # wm
        hyprland

        # users
        user-ryan
      ]
      ++ [
        # disk config
        self.diskoConfigurations.luks-lvm-imp

        # host-specific
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];

    # Variable overrides
    systemOpts = {
      primaryUser = "ryan"; #primary user (not necessarily only user)
      screenDimTimeout = 600;
      lockTimeout = 630;
      screenOffTimeout = 800;
      suspendTimeout = 900;
      diskDevice = "nvme0n1";
      swapEnable = true;
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
      #wifi.backend = "iwd";
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

    # Disable fingerprint for login (causes gnome-keyring unlock to fail).
    # Can still unlock with fingerprint.
    security.pam.services.login.fprintAuth = false;

    # System packages
    environment.systemPackages = with pkgs; [
      blueman
      qdirstat
      zoom-us
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

    # Firmware updates
    services.fwupd.enable = true;

    # pmail bridge must be configured imperatively using the cli tool.
    # State in ~/.config is persisted. Runs as a user service even though
    # it's in system config.
    services.protonmail-bridge = {
      enable = true;
      # make gnome keyring available to bridge in case I'm running KDE
      path = with pkgs; [gnome-keyring];
    };

    # Server for gnome calendar
    services.gnome.evolution-data-server.enable = true;

    # minimal root user config
    users.users.root = {
      hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
    };
  };
}
