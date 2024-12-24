{
  config,
  lib,
  ...
}: {
  options = {
    # ---- SYSTEM SETTINGS ---- #
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
    };

    # ---- USER SETTINGS ---- #
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
  };

  config = {
    _module.args = {
      systemSettings = config.systemSettings;
      userSettings = config.userSettings;
    };
  };
}
