{

  description = "Ryan's Nixos configs";

  inputs = {

    nixpkgs-stable.url = "nixpkgs/nixos-24.05";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";    
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";    
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";    
    };

    mysecrets = {
      url = "git+ssh://git@gitea.dfrp.xyz/ryan/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    impermanence.url = "github:nix-community/impermanence";

    stylix.url = "github:danth/stylix";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, ... } @ inputs:
    let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    in rec {

    nixosConfigurations = {
      nixbook = nixpkgs-unstable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { 
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit secrets;
          inherit inputs;
        };
        modules = [
          ./hosts/nixbook/configuration.nix 
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager-unstable.nixosModules.home-manager
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          inputs.nixos-cosmic.nixosModules.default
          inputs.stylix.nixosModules.stylix
        ];
      };
      nixos-vm = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { 
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit secrets;
          inherit inputs;
        };
        modules = [
          ./hosts/nixos-vm/configuration.nix 
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.home-manager-stable.nixosModules.home-manager
        ];
      };
    };
  };


}
