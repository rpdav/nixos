{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.virtualisation.oci-containers.mounts;
in {
  # Define submodule options
  options.virtualisation.oci-containers.mounts = mkOption {
    description = "Module to ensure folders for container bind-mounts are created/restored and with proper ownership";
    default = {};
    type = types.attrsOf (
      types.submodule ({name, ...}: {
        options = {
          target = mkOption {
            type = types.str;
            default = "${config.serviceOpts.dockerDir}/${name}/config";
          };
          mode = mkOption {
            type = types.str;
            default = "0700";
          };
          user = mkOption {
            type = types.str;
            default = config.serviceOpts.dockerUser;
          };
          group = mkOption {
            type = types.str;
            default = "users";
          };
        };
      })
    );
  };

  config = {
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (
        key: val: let
          # Create the directory if it doesn't exist. Docker command will fail if the directory doesn't exist.
          createRule = "d ${val.target} ${val.mode} ${val.user} ${val.group}";
          # Recursively correct ownership. If restoring with nixos-anywhere, it doesn't preserve ownership when copying over data.
          permissionRule = "Z ${val.target} - ${val.user} ${val.group}";
        in [
          createRule
          permissionRule
        ]
      )
      cfg);
  };
}
