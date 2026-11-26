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
        set -eo pipefail

        hostname="''${1}"
        mode="''${2:-switch}" # Default to "switch" if not provided

        if [ -z "$hostname" ]; then
            echo "Error: Hostname argument is required."
            echo "Usage: $0 <hostname|all> [mode]"
            exit 1
        fi

        # Make nixos-rebuild's ssh/nix-copy calls reuse the masters opened by ssh_auth.
        # The ControlPath must match your ssh config.
        export NIX_SSHOPTS="-o ControlMaster=auto -o ControlPath=$HOME/.ssh/cm-%C -o ControlPersist=30m"

        ssh_auth() {
            local host="$1"
            echo "========================================"
            echo "Authenticating host: ''${host}"
            echo "========================================"
            ssh root@"$host" true
        }

        build_host() {
            local host="$1"
            echo "========================================"
            echo "Building host: ''${host}"
            echo "========================================"
            nix build --log-format internal-json -v \
              -o ~/hosts/"''${host}"/build \
              ${config_location}#nixosConfigurations."''${host}".config.system.build.toplevel \
              |& ${pkgs.nix-output-monitor}/bin/nom --json
        }

        deploy_host() {
            local host="$1"
            local run_mode="$2"
            echo "========================================"
            echo "Deploying host: ''${host} (Mode: ''${run_mode})"
            echo "========================================"
            nixos-rebuild --flake ${config_location}#"''${host}" --target-host root@"''${host}" "''${run_mode}" |& ${pkgs.nix-output-monitor}/bin/nom
        }

        # Collect hosts
        hosts=()
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

                    hosts+=("$base_dir")
                fi
            done
        else
            hosts=("$hostname")
        fi

        # Close the persistent masters when the script ends
        cleanup() {
            for h in "''${hosts[@]}"; do
                ssh -O exit root@"$h" 2>/dev/null || true
            done
        }
        trap cleanup EXIT

        # Phase 1: all touches up front
        for h in "''${hosts[@]}"; do ssh_auth "$h"; done

        # Phase 2: build everything
        for h in "''${hosts[@]}"; do build_host "$h"; done

        # Phase 3: deploy everything
        failed=()
        for h in "''${hosts[@]}"; do
            if ! deploy_host "$h" "$mode"; then
                echo "!!! Deployment FAILED for host: ''${h}" >&2
                failed+=("$h")
            fi
        done
        
        if [ "''${#failed[@]}" -gt 0 ]; then
            echo "========================================" >&2
            echo "Deployment failed for: ''${failed[*]}" >&2
            exit 1
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

      # Stable packages
      _module.args.pkgs-stable = import inputs.nixpkgs-stable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (config.nixpkgs) config;
      };

      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes pipe-operators
          keep-outputs = true
          keep-derivations = true
          warn-dirty = false
          !include ${config.sops.templates."githubPAT".path}
        '';
        # Set nixpkgs to drop unused channel path
        # which causes eval warnings
        settings.nix-path = ["nixpkgs=${inputs.nixpkgs}"];
      };

      # Binary cache
      sops.secrets."attic/token".sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      sops.templates."attic-netrc" = {
        # owner defaults to root, which matches what the nix daemon needs
        content = ''
          machine nix.dfrp.xyz
          password ${config.sops.placeholder."attic/token"}
        '';
      };
      nix.settings.netrc-file = config.sops.templates."attic-netrc".path;

      environment.systemPackages = [
        buildScript # Remote build helper
        pkgs.attic-client
      ];

      environment.shellAliases."nd" = "nixos-deploy";

      # Cache substituters
      # Putting all config-wide substituters here so that hosts
      # can use them for building even if they aren't needed for all hosts.
      nix.settings = {
        substituters = [
          "https://nix.${inputs.nix-secrets.selfhosting.domain}/nixos-cache"
          "https://nvf.cachix.org"
          "https://hyprland.cachix.org"
          "https://watersucks.cachix.org"
          "https://noctalia.cachix.org"
        ];
        trusted-public-keys = [
          "nixos-cache:tURmQMVstXX1SRGXf0D6XWmTUnHLH0+7rHTQDE8ag/o="
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
