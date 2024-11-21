{ config, lib, ... }:
{

  options = {
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Indiana/Indianapolis";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
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
    };

    # ---- USER SETTINGS ---- #
    userSettings = {
      editor = lib.mkOption {
        type = lib.types.str;
        default = "vim";
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
      wm = lib.mkOption {
        type = lib.types.str;
        default = "kde";
      };
      theme = lib.mkOption {
        type = lib.types.str;
        default = "mountain";
      };
     base16theme = lib.mkOption {
        type = lib.types.str;
        default = "3024"; #run nix build nixpkgs#base16-schemes and browse result/share/themes
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
