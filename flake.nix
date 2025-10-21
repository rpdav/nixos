{
  #some more changes
  description = "Ryan's Nixos configs";

  inputs = {
    ###### Official Sources ######

    # Default nixpkgs
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # Explicitly-defined stable and unstable as alternates
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###### Utilities ######

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative VM management
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware configs
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Docker utilities
    uptix = {
      url = "github:luizribeiro/uptix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-friendly editor
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Useful options search and cli tools
    nixos-cli.url = "github:nix-community/nixos-cli";

    # Interactive pkgs search
    nsearch = {
      url = "github:niksingh710/nsearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bleeding-edge AI tools
    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    ###### GUI stuff ######

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    ###### Personal repos ######

    # Private secrets repo
    nix-secrets = {
      url = "git+file:///home/ryan/nix-secrets";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-stable,
    ...
  } @ inputs: let
    secrets = import ./vars/secrets {inherit inputs;};
    inherit (nixpkgs-unstable) lib;

    configLib = import ./lib {inherit lib;};
    system = "x86_64-linux";

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    specialArgs = {
      inherit pkgs-stable;
      inherit pkgs-unstable;
      inherit secrets;
      inherit inputs;
      inherit (self) outputs;
      inherit configLib;
    };
  in {
    nixosModules = import ./modules/nixos;

    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      # 2023 Framework 13
      fw13 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./hosts/fw13];
      };
      # Linode VPS
      vps = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./hosts/vps];
      };
      # Ryzen 5 3600 NAS and virtualization host
      nas = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./hosts/nas];
      };
      # Asus vivobook
      vivobook = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./hosts/vivobook];
      };
      # Testing VM
      testvm = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [./hosts/testvm];
      };
    };
  };
}
