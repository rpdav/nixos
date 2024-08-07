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
      ##TODO: add logic to set wmType based on wm
      wmType = lib.mkOption {
        type = lib.types.str;
        default = "wayland";
      };
    };
  };

  config = {
    _module.args = {
      systemSettings = config.systemVars;
      userSettings = config.userVars;
    };
  };

}
