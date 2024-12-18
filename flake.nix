{
  #some more changes
  description = "Ryan's Nixos configs";

  inputs = {
    ###### Official Sources ######
    
    # Default nixpkgs
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # Explicitly-defined stable and unstable as alternates
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ###### Utilities ######

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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

    # Useful option search and CLI tools
    nixos-cli.url = "github:water-sucks/nixos";

    # Theming
    stylix.url = "github:danth/stylix";

    # Nix-friendly editor
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ###### GUI stuff ######

    # Declarative plasma config
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    # Cosmic alpha
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ###### Personal repos ######

    # Private secrets repo
    nix-secrets = {
      url = "https://git.dfrp.xyz/ryan/nix-secrets.git?ref=main&shallow=1";
      type = "git";
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
  in
  {
    #TODO The 2 lines below came from EmergentMind's config for yubikey support, but doesn't work for me
    # for some reason. Instead, I'm importing in each host's modules list.
    #nixosModules = import ./modules/nixos;
    #homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      # 2023 Framework 13
      fw13 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { 
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit secrets;
          inherit inputs;
          inherit configLib;
        };
        modules = [
          # See notes at top of outputs
          (import ./modules/nixos)
          ./hosts/fw13
	  #TODO clean this up - maybe put it in host's main module or core module?
	  inputs.lanzaboote.nixosModules.lanzaboote
          inputs.disko.nixosModules.disko
          inputs.nixvim.nixosModules.nixvim
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager-unstable.nixosModules.home-manager
          inputs.nixos-cli.nixosModules.nixos-cli
          inputs.stylix.nixosModules.stylix
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          inputs.nixos-cosmic.nixosModules.default
        ];
      };
      # Testing box (HP x86 thin client)
      # nixos-anywhere --flake .#testbox --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --copy-host-keys testbox
      nixosConfigurations.testbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/testbox
          ./hosts/testbox/hardware-configuration.nix
        ];
      };
    };
  };
}
