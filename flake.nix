# Generation 193
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

    impermanence.url = "github:nix-community/impermanence";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
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
        };
        modules = [

          ./hosts/nixbook/system/configuration.nix 

          inputs.impermanence.nixosModules.impermanence

          inputs.home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./hosts/nixbook/user/home.nix;
            home-manager.sharedModules = with inputs; [ 
              plasma-manager.homeManagerModules.plasma-manager 
              impermanence.nixosModules.home-manager.impermanence
            ];
            home-manager.extraSpecialArgs = {
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
              inherit secrets;
            };
          }
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
        };
        modules = [

          ./hosts/nixos-vm/configuration.nix 

          inputs.disko.nixosModules.disko

          inputs.impermanence.nixosModules.impermanence

          inputs.home-manager-stable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./hosts/nixos-vm/home.nix;
            home-manager.sharedModules = with inputs; [ 
              impermanence.nixosModules.home-manager.impermanence
            ];
            home-manager.extraSpecialArgs = {
              pkgs-unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
              inherit secrets;
            };
          }
        ];
      };
    };
  };


}
