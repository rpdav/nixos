{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "DP-1";
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 60;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        scaling = mkOption {
          type = types.float;
          default = 1.0;
          example = 2.0;
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
        };
      };
    });
    default = [];
  };
}
