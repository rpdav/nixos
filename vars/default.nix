{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    # ---- SYSTEM SETTINGS ---- #
    systemOpts = {
      primaryUser = mkOption {
        type = types.str;
        default = "ryan";
        description = ''
          Primary user for the system.

          Used for system settings that are required to run under a user account.
        '';
      };
      impermanent = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether impermanence is enabled for the system. This bool is used to enable impermanence-specific tweaks.
        '';
      };
      gui = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether the system has a gui.
        '';
      };
      swapEnable = mkOption {
        type = types.bool;
        default = "true";
        description = ''
          Whether swap is enabled for the system.
        '';
      };
      swapSize = mkOption {
        type = types.str;
        default = "8G";
        description = ''
          Swap size in the format of [number][K/M/G].
        '';
      };
      diskDevice = mkOption {
        type = types.str;
        default = "/dev/nvme01n1";
        description = ''
          Primary disk device to be partitioned by disko.

          After partitioning, the device is mounted by label, so there is no concern of `/dev/sda` being swapped with another disk after reboot.

          Just check that the device is correct during the install session.
        '';
      };
      gcRetention = mkOption {
        type = types.str;
        default = "30d";
        description = ''
          How long to keep builds in the format of `[number of days]d`.
        '';
      };
      persistVol = mkOption {
        type = types.str;
        default = "/persist";
        description = ''
          Where to mount the persistent drive. Only applies to impermanent systems.
        '';
      };
      screenDimTimeout = mkOption {
        type = types.ints.positive;
        default = 150;
        description = ''
          Time in seconds until screen dims.
        '';
      };
      lockTimeout = mkOption {
        type = types.ints.positive;
        default = 300;
        description = ''
          Time in seconds until system is locked.
        '';
      };
      screenOffTimeout = mkOption {
        type = types.ints.positive;
        default = 330;
        description = ''
          Time in seconds until screen turns off.
        '';
      };
      suspendTimeout = mkOption {
        type = types.ints.positive;
        default = 600;
        description = ''
          Time in seconds until system suspends.
        '';
      };
    };

    # ---- USER SETTINGS ---- #
    userOpts = {
      theme = mkOption {
        # Type is enum with allowed values being the contents of the theme folder
        # in the root of the repo.
        type = builtins.readDir "${inputs.self.outPath}/themes" |> lib.attrNames |> types.enum;
        default = "mountain";
        description = ''
          Theme to use. One of the themes folders in the root of the repo.
        '';
      };
      cursor = mkOption {
        type = types.str;
        default = "Vanilla-DMZ";
        description = ''
          Cursor name
        '';
      };
      cursorPkg = mkOption {
        type = types.str;
        default = "vanilla-dmz";
        description = ''
          Cursor package
        '';
      };
      font = mkOption {
        type = types.str;
        default = "";
        description = ''
          Font name
        '';
      };
      fontPkg = mkOption {
        type = types.str;
        default = "nerd-fonts.fira-code";
        description = ''
          Font package
        '';
      };
      impermanent = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Boolean for whether to enable user impermanent directories
        '';
      };
    };

    # ---- BACKUP SETTINGS ---- #
    backupOpts = {
      localRepo = mkOption {
        type = types.str;
        default = "ssh://borg@10.10.1.17:2222/backup";
        description = ''
          Local backup target
        '';
      };
      remoteRepo = mkOption {
        type = types.str;
        default = "/mnt/B2/borg or something";
        description = ''
          B2 backup target after mounting
        '';
      };
      paths = mkOption {
        type = types.listOf types.str;
        default = [config.systemOpts.persistVol];
        description = ''
          Path(s) to back up
        '';
      };
      patterns = mkOption {
        type = types.listOf types.str;
        default = [""];
        description = ''
          List of borg patterns
        '';
        example = [
          " - **/.git"
          " - **/.Trash*"
        ];
      };
    };

    # ---- SERVICES SETTINGS ---- #
    serviceOpts = {
      dockerUser = mkOption {
        type = types.str;
        default = config.systemOpts.primaryUser;
        description = ''
          User under which to run docker services
        '';
      };
      dockerDir = mkOption {
        type = types.str;
        default = "/opt/docker";
        description = ''
          Where to store docker appdata
        '';
      };
      proxyDir = mkOption {
        type = types.str;
        default = "${config.serviceOpts.dockerDir}/swag/proxy-confs";
        description = ''
          Where to store swag proxy configs
        '';
      };
    };
  };
}
