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
      url = "git+https://git.dfrp.xyz/ryan/nix-secrets";
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
    system = "x86_64-linux";

    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # Secrets & library helpers
    secrets = import ./vars/secrets {inherit inputs;};
    configLib = import ./lib {inherit (nixpkgs-unstable) lib;};

    specialArgs = {
      inherit pkgs-stable secrets inputs configLib;
      inherit (self) outputs;
    };

    # Config generator function
    mkConfigurations = hosts:
      hosts
      # Map each hostname to a name-value pair
      |> map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [./system/hosts/${host}];
        };
      })
      # Convert the list of pairs into a single attribute set
      |> builtins.listToAttrs;
  in {
    ######################################################################
    # Exported modules
    ######################################################################
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    ######################################################################
    # Generate nixosConfigurations based on helper function and host list
    ######################################################################
    nixosConfigurations = mkConfigurations [
      # Main hosts
      "fw13"
      "nas"
      "vps"
      # Installation configs
      "install"
      "iso"
      # Testing hosts
      "vivobook"
      "testvm"
    ];
  };
}
