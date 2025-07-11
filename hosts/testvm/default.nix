{
  lib,
  pkgs,
  configLib,
  inputs,
  systemOpts,
  userOpts,
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
        #"hosts/common/optional/backup"
        #"hosts/common/optional/duplicati.nix"
        "hosts/common/optional/persistence"
        "hosts/common/optional/stylix.nix"
        "hosts/common/optional/wm/cinnamon.nix"
        "hosts/common/optional/yubikey.nix"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      inputs.nixos-cli.nixosModules.nixos-cli
    ];

  # Variable overrides
  userOpts = {
    username = "ryan"; #primary user (not necessarily only user)
    term = "kitty";
  };
  systemOpts = {
    diskDevice = "vda";
    swapSize = "6G";
    impermanent = true;
    gui = true;
  };
  #backupOpts = {
  #  localRepo = "ssh://borg@borg:2222/backup";
  #  remoteRepo = "/mnt/B2/borg";
  #  sourcePaths = [config.systemOpts.persistVol];
  #  excludeList = [
  #    # Run `borg help patterns` for guidance on exclusion patterns
  #    "*/var/**" #not needed for restore
  #    "**/.git" #can be restored from repos
  #    "**/.Trash*" #automatically made by gui deletions
  #    "**/.local/share/libvirt" #vdisks made mostly for testing
  #    "*/home/*/Downloads/" #big files
  #    "*/home/ryan/Nextcloud" #already on server
  #    "*/home/*/.thunderbird/*/ImapMail" #email
  #    "*/home/*/.local/share/Steam" #lots of small files and big games
  #    "*/home/*/.local/share/lutris" #lots of small files and big games
  #    "*/home/*/.local/share/protonmail" #email
  #  ];
  #};

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Networking
  networking.hostName = "testvm";
  networking.networkmanager.enable = true;

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

  # System packages
  environment.systemPackages = with pkgs; [
    qdirstat
  ];

  # Create impermanent directories
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "/var/lib/bluetooth"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # Options search
  services.nixos-cli = {
    enable = true;
    config = {
      config_location = "/home/${userOpts.username}/nixos";
      apply.use_git_commit_msg = true;
      apply.imply_impure_with_tag = true;
      apply.use_nom = true;
    };
  };
  nix.settings = {
    substituters = ["https://watersucks.cachix.org"];
    trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };

  # Add justfile at root
  systemd.tmpfiles.rules = [
    "f /justfile 0644 ${config.userOpts.username} users - import \\'/home/${config.userOpts.username}/nixos/justfile\\'"
  ];

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
}
