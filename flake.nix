{
  description = "Ryan's NixOS configs";

  ##########################################################################
  # INPUTS
  ##########################################################################
  inputs = {
    # ── Core Nixpkgs ────────────────────────────────────────
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # ── Home‑manager ────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Utility flakes – most just follow nixpkgs ───────────────
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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cli.url = "github:nix-community/nixos-cli";
    nsearch = {
      url = "github:niksingh710/nsearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    # ── GUI‑related flakes ───────────────────────────────────────
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ── Personal / secret repos ─────────────────────────────────
    nix-secrets = {
      url = "git+file:///home/ryan/nix-secrets";
    };
  };

  ##########################################################################
  # OUTPUTS
  ##########################################################################
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-stable,
    ...
  } @ inputs: let
    ######################################################################
    # Shared helpers
    ######################################################################
    system = "x86_64-linux";

    # Unfree‑enabled package sets
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # Secrets & library helpers (imported once)
    secrets = import ./vars/secrets {inherit inputs;};
    lib = nixpkgs-unstable.lib;
    configLib = import ./lib {inherit (nixpkgs-unstable) lib;};

    # Arguments passed to every host/module
    specialArgs = {
      inherit pkgs-stable pkgs-unstable secrets inputs configLib;
      inherit (self) outputs;
    };

    # --------------------------------------------------------------------
    # Helper to build a NixOS system from a module path
    # --------------------------------------------------------------------
    mkHost = modulePath:
      nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [modulePath];
      };

    # --------------------------------------------------------------------
    # Dynamically discover sub‑directories under ./system/hosts
    # --------------------------------------------------------------------
    hostNames =
      builtins.readDir ./system/hosts
      |> lib.attrNames;

    generatedConfigs =
      hostNames
      |> map (name: {
        name = name;
        value = mkHost (./system/hosts + "/${name}");
      })
      |> lib.listToAttrs;
  in {
    ######################################################################
    # Exported modules
    ######################################################################
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    ######################################################################
    # Auto‑generated host configs based on ./system/hosts directory
    ######################################################################
    nixosConfigurations = generatedConfigs;
  };
}
