{

  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";    
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs"; #this may not be needed
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      nixbook = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          ./configuration.nix 
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./home.nix;
          }
        ];
      };
#      nixbook = nixpkgs.lib.nixosSystem {
#        inherit system;
#        modules = [
#          impermanence.nixosModules.impermanence
#          .configuration.nix
#        ];
#      };
    };
  };
}
