{
  lib,
  pkgs,
  configLib,
  inputs,
  config,
  ...
}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
  inherit (config) systemOpts;
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
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    diskDevice = "vda";
    swapSize = "6G";
    impermanent = true;
    gui = true;
  };

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

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
  };
}
