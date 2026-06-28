{
  inputs,
  lib,
  moduleLocation,
  self,
  ...
}: let
  inherit (lib) mkOption types mapAttrs;
in {
  imports = [
    inputs.flake-parts.flakeModules.modules # expose `flake.modules.X` for reusable modules
  ];
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
          Self-hosted service modules.

          You may use this for self-hosted service configurations,
          whether using docker/podman or native nixos services.
        '';
      };
    };
  };
  config = {
    # Systems to build packages for with perSystem
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    flake.nixosModules.nix = {config, ...}: {
      # Enable flakes
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes pipe-operators
          keep-outputs = true
          keep-derivations = true
          warn-dirty = false
        '';
      };

      # Cache substituters
      # Putting all config-wide substituters here so that hosts
      # can use them for building even if they aren't needed for all hosts.
      nix.settings = {
        substituters = [
          "https://nvf.cachix.org"
          "https://hyprland.cachix.org"
          "https://watersucks.cachix.org"
          "https://nixos-raspberrypi.cachix.org"
          "https://noctalia.cachix.org"
        ];
        trusted-public-keys = [
          "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
          "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      # Automate garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than ${config.systemOpts.gcRetention}";
      };
      # Put link to current flake in etc for ease of reference
      environment.etc."current-system-flake".source = self;
    };
  };
}
