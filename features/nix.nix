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
    flake.nixosModules.nix = {
      config,
      pkgs,
      ...
    }: let
      config_location = config.programs.nixos-cli.settings.config_location;
      # Not putting buildScript into flake.perSystem because it depends on config
      buildScript = pkgs.writeShellScriptBin "nixos-deploy" ''
        set -e

        # Assign arguments to variables
        hostname="''${1}"
        mode="''${2:-switch}" # Default to "switch" if not provided

        # Check if the hostname argument was provided
        if [ -z "$hostname" ]; then
            echo "Error: Hostname argument is required."
            echo "Usage: $0 <hostname|all> [mode]"
            exit 1
        fi

        # Function to build and deploy a single host
        run_nixos_commands() {
            local host="$1"
            local run_mode="$2"

            echo "========================================"
            echo "Building host: ''${host}"
            echo "========================================"

            nixos apply ${config_location}#"''${host}" --no-boot --no-activate -o ~/hosts/"''${host}"/build

            echo "========================================"
            echo "Deploying host: ''${host} (Mode: ''${run_mode})"
            echo "========================================"

            nixos-rebuild --flake ${config_location}#"''${host}" --target-host root@"''${host}" "''${run_mode}"
        }

        # Loop through hostnames if provided hostname is "all"
        if [ "$hostname" = "all" ]; then
            hosts_dir="$HOME/hosts"

            if [ ! -d "$hosts_dir" ]; then
                echo "Error: Directory ''${hosts_dir} does not exist."
                exit 1
            fi

            for dir in "$hosts_dir"/*; do
                if [ -d "$dir" ]; then
                    base_dir=$(basename "$dir")

                    # Ignore _directories which are used for testing
                    if [[ "$base_dir" =~ ^_ ]]; then
                        continue
                    fi

                    run_nixos_commands "$base_dir" "$mode"
                fi
            done
        else
            run_nixos_commands "$hostname" "$mode"
        fi

        echo "Deployment complete"

      '';
    in {
      # Decrypt and set up github PAT for use by nix
      sops.secrets."github/PAT".sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      sops.templates.githubPAT = {
        content = ''
          access-tokens = github.com=${config.sops.placeholder."github/PAT"}
        '';
        mode = "0444"; # needed for non-sudo nix operations like remote deploy and nix flake check
      };

      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes pipe-operators
          keep-outputs = true
          keep-derivations = true
          warn-dirty = false
          !include ${config.sops.templates."githubPAT".path}
        '';
      };

      environment.systemPackages = [
        buildScript # Remote build helper
      ];

      environment.shellAliases."nd" = "nixos-deploy";

      # Cache substituters
      # Putting all config-wide substituters here so that hosts
      # can use them for building even if they aren't needed for all hosts.
      nix.settings = {
        substituters = [
          "https://nvf.cachix.org"
          "https://hyprland.cachix.org"
          "https://watersucks.cachix.org"
          "https://noctalia.cachix.org"
        ];
        trusted-public-keys = [
          "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
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
