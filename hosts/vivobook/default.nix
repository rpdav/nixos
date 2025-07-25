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
        "hosts/common/optional/wm/cinnamon.nix"

        # users
        "hosts/common/users/ryan"
        "hosts/common/users/ariel"
      ])

      # host-specific
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

  # Variable overrides
  userOpts = {
    primaryUser = "ariel"; #primary user (not necessarily only user)
    term = "kitty";
  };
  systemOpts = {
    diskDevice = "vda";
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
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/bluetooth"
    ];
    files = [
      "/root/.ssh/known_hosts"
    ];
  };

  # Firmware updates
  services.fwupd.enable = true;

  # minimal root user config
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
}
