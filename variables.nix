{ config, lib, ... }:
{

  options = {
    systemVars.asdf = lib.mkOption {
      type = lib.types.str;
      default = { };
    };
    userVars = lib.mkOption {
      type = lib.types.str;
      default = { };
    };
  };

  config = {
    _module.args = {
      systemVars = config.systemVars;
      userVars = config.userVars;
    };
    
    systemVars.asdf = "default1";
  };

}
