{
  config,
  lib,
  userOpts,
  ...
}: {
  options = {
    # ---- SYSTEM SETTINGS ---- #
    systemOpts = {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Indiana/Indianapolis";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
      };
      impermanent= lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      gui= lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      swapEnable = lib.mkOption {
        type = lib.types.bool;
        default = "true";
      };
      swapSize = lib.mkOption {
        type = lib.types.str;
        default = "8G";
      };
      diskDevice = lib.mkOption {
        type = lib.types.str;
        default = "/dev/nvme01n1";
      };
      hibernate = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      arch = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
      };
      gcInterval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
      };
      gcRetention = lib.mkOption {
        type = lib.types.str;
        default = "30d";
      };
      persistVol = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
      };
    };

    # ---- USER SETTINGS ---- #
    userOpts = {
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Ryan";
      };
      term = lib.mkOption {
        type = lib.types.str;
        default = "kitty";
      };
      githubEmail = lib.mkOption {
        type = lib.types.str;
        default = "105075689+rpdav@users.noreply.github.com";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "ryan";
      };
      base16scheme = lib.mkOption {
        type = lib.types.str;
        default = "3024"; #run nix build nixpkgs#base16-schemes and browse result/share/themes
      };
      wallpaper = lib.mkOption {
        type = lib.types.str;
        default = "squares"; 
      };
      cursor = lib.mkOption {
	type = lib.types.str;
	default = "Vanilla-DMZ";
      };
      cursorPkg = lib.mkOption {
	type = lib.types.str;
	default = "vanilla-dmz";
      };
      font = lib.mkOption {
	type = lib.types.str;
	default = "";
      };
      fontPkg = lib.mkOption {
	type = lib.types.str;
	default = "nerd-fonts.fira-code";
      };
    };

    # ---- BACKUP SETTINGS ---- #
    backupOpts = {
      localRepo = lib.mkOption {
	type = lib.types.str;
	default = "ssh://borg@10.10.1.17:2222/backup";
	description = "Local backup target";
      };
      remoteRepo = lib.mkOption {
	type = lib.types.str;
	default = "/mnt/B2/borg or something";
	description = "B2 backup target after mounting";
      };
      sourcePaths = lib.mkOption {
	type = lib.types.listOf lib.types.str;
	default = [config.systemOpts.persistVol];
	description = "Path(s) to back up";
      };
      excludeList = lib.mkOption {
	type = lib.types.listOf lib.types.str;
	default = [ ".git/**" "etcetera" ]; 
	description = "List of paths and files to exclude";
      };
    };

    # ---- SERVICES SETTINGS ---- #
    serviceOpts = {
      dockerUser = lib.mkOption {
	type = lib.types.str;
	default = userOpts.username;
	description = "User under which to run docker services";
      };
      dockerDir = lib.mkOption {
	type = lib.types.str;
	default = "/opt/docker";
	description = "Where to store docker appdata";
      };
    };
  };

  config = {
    _module.args = {
      systemOpts = config.systemOpts;
      userOpts = config.userOpts;
      serviceOpts = config.serviceOpts;
      backupOpts = config.backupOpts;
    };
  };
}
