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

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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

    # Hardware configs
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    # Nix-friendly editor
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Useful options search
    nixos-cli = {
      url = "github:water-sucks/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###### GUI stuff ######

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager-unstable";
      };
    };

    ###### Personal repos ######

    # Private secrets repo
    nix-secrets = {
      url = "git+ssh://git@github.com/rpdav/nix-secrets.git?ref=main&shallow=1";
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
      inherit configLib;
    };
  in {
    #TODO The 2 lines below came from EmergentMind's config for yubikey support, but doesn't work for me
    # for some reason. Instead, I'm importing in each host's modules list.
    #nixosModules = import ./modules/nixos;
    #homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      # 2023 Framework 13
      fw13 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          # See notes at top of outputs
          (import ./modules/nixos)
          ./hosts/fw13
          inputs.home-manager-unstable.nixosModules.home-manager
        ];
      };
      # Linode VPS
      vps = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          (import ./modules/nixos)
          ./hosts/vps
          inputs.home-manager-stable.nixosModules.home-manager
        ];
      };
      # Ryzen 5 3600 NAS and virtualization host
      nas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          (import ./modules/nixos)
          ./hosts/nas
          inputs.home-manager-unstable.nixosModules.home-manager
        ];
      };
      # Testing box (HP x86 thin client)
      testbox = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          ./hosts/testbox
        ];
      };
      # Testing VM (QEMU VM running on Unraid)
      testvm = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;
        modules = [
          (import ./modules/nixos)
          ./hosts/testvm
          inputs.home-manager-stable.nixosModules.home-manager
        ];
      };
    };
  };
}
