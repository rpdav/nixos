{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    # ---- SYSTEM SETTINGS ---- #
    systemOpts = {
      impermanent = mkOption {
        type = types.bool;
        default = true;
      };
      gui = mkOption {
        type = types.bool;
        default = false;
      };
      swapEnable = mkOption {
        type = types.bool;
        default = "true";
      };
      swapSize = mkOption {
        type = types.str;
        default = "8G";
      };
      diskDevice = mkOption {
        type = types.str;
        default = "/dev/nvme01n1";
      };
      gcInterval = mkOption {
        type = types.str;
        default = "weekly";
      };
      gcRetention = mkOption {
        type = types.str;
        default = "30d";
      };
      persistVol = mkOption {
        type = types.str;
        default = "/persist";
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
      name = mkOption {
        type = types.str;
        default = "Ryan";
      };
      term = mkOption {
        type = types.str;
        default = "kitty";
      };
      githubEmail = mkOption {
        type = types.str;
        default = "105075689+rpdav@users.noreply.github.com";
      };
      primaryUser = mkOption {
        type = types.str;
        default = "ryan";
      };
      base16scheme = mkOption {
        type = types.str;
        default = "3024"; #run nix build nixpkgs#base16-schemes and browse result/share/themes
      };
      wallpaper = mkOption {
        type = types.str;
        default = "mountain";
      };
      cursor = mkOption {
        type = types.str;
        default = "Vanilla-DMZ";
      };
      cursorPkg = mkOption {
        type = types.str;
        default = "vanilla-dmz";
      };
      font = mkOption {
        type = types.str;
        default = "";
      };
      fontPkg = mkOption {
        type = types.str;
        default = "nerd-fonts.fira-code";
      };
      impermanent = mkOption {
        type = types.bool;
        default = true;
        description = "Boolean for whether to enable user impermanent directories";
      };
    };

    # ---- BACKUP SETTINGS ---- #
    backupOpts = {
      localRepo = mkOption {
        type = types.str;
        default = "ssh://borg@10.10.1.17:2222/backup";
        description = "Local backup target";
      };
      remoteRepo = mkOption {
        type = types.str;
        default = "/mnt/B2/borg or something";
        description = "B2 backup target after mounting";
      };
      paths = mkOption {
        type = types.listOf types.str;
        default = [config.systemOpts.persistVol];
        description = "Path(s) to back up";
      };
      patterns = mkOption {
        type = types.listOf types.str;
        default = [""];
        description = "list of borg patterns";
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
        default = config.userOpts.primaryUser;
        description = "User under which to run docker services";
      };
      dockerDir = mkOption {
        type = types.str;
        default = "/opt/docker";
        description = "Where to store docker appdata";
      };
      proxyDir = mkOption {
        type = types.str;
        default = "${config.serviceOpts.dockerDir}/swag/proxy-confs";
        description = "Where to store swag proxy configs";
      };
    };
  };
}
