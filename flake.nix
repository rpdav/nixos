{
  description = "Ryan's NixOS configs";

  inputs = {
    # ── Core Nixpkgs ────────────────────────────────────────
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";

    # ── Home‑manager ────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Flake-Parts tools ───────────────────────────────────
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # flake-parts does not use nixpkgs as an input; no override
    };
    import-tree = {
      url = "github:vic/import-tree";
      # import-tree does not use nixpkgs as an input; no override
    };

    # ── Utility flakes ──────────────────────────────────────
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

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    # Import all .nix files, omitting files/dirs starting with "_" and flake.nix.
    (inputs.import-tree.filterNot (inputs.nixpkgs.lib.hasInfix "flake.nix") ./.);
}
