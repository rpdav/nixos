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

  # Disable module if config.systemOpts.proxyDir is not set. Prevents errors when the submodule is imported but no options defined.
  # Would be cleaner to have an enable option but I'm not sure how to do that for types.attrsOf (types.submodule)
  #lib.mkIf (!(isNull config.serviceOpts.proxyDir))
  config = {
    systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (
        key: val: let
          # Create the directory if it doesn't exist. Docker command will fail if the directory doesn't exist.
          createRule = "d ${val.target} ${val.mode} ${val.user} ${val.group}";
          # Recursively
          permissionRule = "Z ${val.target} - ${val.user} ${val.group}";
        in [
          # Make sure file is deleted first, then recreated
          createRule
          permissionRule
        ]
      )
      cfg);
  };
}
