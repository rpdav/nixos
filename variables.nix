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
      username = lib.mkOption {
        type = lib.types.str;
        default = "ryan";
      };
      wm = lib.mkOption {
        type = lib.types.str;
        default = "kde";
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
