{
  modulesPath,
  lib,
  pkgs,
  config,
  configLib,
  ...
}: let
  inherit (config.systemOpts) persistVol impermanent;
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../../common/users/ryan/keys;
in {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "system/common/core"

        # disk config
        "system/common/disks/luks-lvm-imp.nix"

        # optional config
        "system/common/optional/backup"
        "system/common/optional/docker.nix"
        "system/common/optional/persistence"
        #"system/common/optional/ssh-unlock.nix"
        "system/common/optional/virtualization"
        "system/common/optional/yubikey.nix"

        # services
        "services/common"
        "services/nas"

        # users
        "system/common/users/ryan"
      ])

      # host-specific
      ./win-vm
      ./hardware-configuration.nix
      ./zfs
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    swapEnable = true;
    diskDevice = "nvme0n1";
    swapSize = "16G";
    gcRetention = "30d";
    impermanent = true;
    gui = false;
  };
  serviceOpts = {
    dockerDir = "/mnt/docker/appdata";
    proxyDir = "/run/selfhosting/proxy-confs";
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
      "- */home/*/.git/**" #can be restored from repo
      "- **/.local/share/libvirt" #root and user vm images
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

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
