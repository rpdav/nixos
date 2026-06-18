{
  description = "Ryan's NixOS configs";

  ##########################################################################
  # INPUTS
  ##########################################################################
  inputs = {
    # ── Core Nixpkgs ────────────────────────────────────────
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";

    # ── Home‑manager ────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Utility flakes ──────────────────────────────────────
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # flake-parts does not use nixpkgs as an input; no override
    };
    import-tree = {
      url = "github:vic/import-tree";
      # import-tree does not use nixpkgs as an input; no override
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # nixos-hardware does not use nixpkgs as an input; no override
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    uptix = {
      url = "github:luizribeiro/uptix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      # separate cache server - no follow nixpkgs
    };
    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      # separate cache server - no follow nixpkgs
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
      # separate cache server - no follow nixpkgs
    };

    # ── GUI‑related flakes ───────────────────────────────────────
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # separate cache server - no follow nixpkgs
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ── Personal / secret repos ─────────────────────────────────
    nix-secrets = {
      url = "git+https://git.dfrp.xyz/ryan/nix-secrets";
    };
  };

  ##########################################################################
  # OUTPUTS
  ##########################################################################
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;} {
      imports = [
        inputs.home-manager.flakeModules.home-manager # needed to merge homeModules. Move to config later
        # Add modules here as they are brought into flake-parts
        # Once conversion is done, this will be replaced with import-tree
        # This list will get really long

        # general modules
        ./modules/nixos
        ./modules/home-manager
        ./vars

        # disk configs
        ./system/common/disks/luks-lvm-imp.nix
        ./system/common/disks/btrfs-imp.nix

        # system modules
        ./system/common/core
        ./system/common/optional/vim.nix
        ./system/common/optional/backup
        ./system/common/optional/docker.nix
        ./system/common/optional/duplicati.nix
        ./system/common/optional/plymouth.nix
        ./system/common/optional/ssh-unlock.nix
        ./system/common/optional/steam.nix
        ./system/common/optional/vim.nix
        ./system/common/optional/wifi.nix
        ./system/common/optional/wine.nix
        ./system/common/optional/yubikey.nix
        ./system/common/optional/virtualization
        ./system/common/optional/wm/cinnamon.nix
        ./system/common/optional/wm/hyprland.nix
        ./system/common/optional/wm/retroarch.nix
      ];
      systems = ["x86_64-linux" "aarch64-linux"]; #TODO move this to config?
      flake = {...}: let
        configLib.relativeToRoot = inputs.nixpkgs.lib.path.append ./.;

        specialArgs = {
          inherit configLib inputs;
          inherit (inputs) self;
        };

        # Config generator function
        mkConfigurations = hosts:
          hosts
          # Map each hostname to a name-value pair
          |> map (host: {
            name = host;
            value = inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              modules = [
                ./system/hosts/${host}
              ];
            };
          })
          # Convert the list of pairs into a single attribute set
          |> builtins.listToAttrs;
      in {
        ######################################################################
        # Generate nixosConfigurations based on helper function and host list
        ######################################################################
        nixosConfigurations = mkConfigurations [
          # Main hosts
          "fw13"
          "nas"
          "vps"
          "retropi"
          # Installation configs
          "install"
          "iso"
          # Testing hosts
          "vivobook"
          "testvm"
        ];
      };
    };
}
