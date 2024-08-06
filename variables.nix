{ config, ... }:
{
  options.systemVars = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config._module.args.systemVars = config.systemVars;

  options.userVars = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config._module.args.userVars = config.userVars;

  systemVars.asdf = "default value";
}
