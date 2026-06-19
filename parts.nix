{
  inputs,
  lib,
  moduleLocation,
  ...
}: let
  inherit (lib) mkOption types mapAttrs;
in {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      serviceModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = {};
        apply = mapAttrs (
          k: v: {
            _class = "nixos";
            _file = "${toString moduleLocation}#serviceModules.${k}";
            imports = [v];
          }
        );
        description = ''
          Self-hosted service modules

          You may use this for self-hosted service configurations, whether using
          docker/podman or native nixos services.
        '';
      };
    };
  };
  config = {
    systems = ["x86_64-linux" "aarch64-linux"];
  };
}
