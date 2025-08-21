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
        "hosts/common/core"

        # disk config
        "hosts/common/disks/luks-lvm-imp.nix"

        # optional config
        "hosts/common/optional/backup"
        "hosts/common/optional/duplicati.nix"
        "hosts/common/optional/persistence"
        "hosts/common/optional/steam.nix"
        "hosts/common/optional/wm/hyprland.nix"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix" # container admin tools, not just for running containers
        "hosts/common/optional/virtualization" #commenting out until needed due to long libvirtd restarts
        "hosts/common/optional/wine.nix"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

  # Variable overrides
  userOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
  };
  systemOpts = {
    diskDevice = "nvme0n1";
    swapSize = "16G";
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
    lanzaboote = {
      enable = true;
      pkiBundle = "${persistVol}/etc/secureboot";
    };
  };

  # Networking
  networking.hostName = "fw13";
  networking.networkmanager = {
    enable = true;
    #wifi.backend = "iwd";
  };
  #networking.wireless.iwd.enable = true;

  # Host-specific tailscale config
  # This causes TS to use relays to connect to router and nas when on lan. This is a known issue -
  # https://github.com/tailscale/tailscale/issues/1227. The only way around is to manually add --accept-routes
  # when remote and --reset when on lan. Since this doesn't really cause much issue on LAN, I'm just leaving it.
  services.tailscale.extraUpFlags = ["--accept-routes"]; #accept tailscale routes to LAN while offsite during reauth.

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

  # Disable fingerprint for login (causes gnome-keyring unlock to fail)
  security.pam.services.login.fprintAuth = false;

  # System packages
  environment.systemPackages = with pkgs; [
    qdirstat
    #impala
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

  # pmail bridge must be configured imperatively using the cli tool.
  # State in ~/.config is persisted. Runs as a user service even though
  # it's in system config.
  services.protonmail-bridge = {
    enable = true;
    # make gnome keyring available to bridge in case I'm running KDE
    path = with pkgs; [gnome-keyring];
  };

  # Add justfile at root
  systemd.tmpfiles.rules = [
    "f /justfile 0644 ${config.userOpts.primaryUser}/ users - import \\'/home/${config.userOpts.primaryUser}/nixos/justfile\\'"
  ];

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwordHashRyan".path;
  };
}
