# Generation 64
{

  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";    
    };
    impermanence.url = "github:nix-community/impermanence";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, impermanence, nur, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    in rec {

    nixosConfigurations = {
      nixbook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit secrets;
        };
        modules = [

          ./configuration.nix 

          # nur overlay
          { nixpkgs.overlays = [ nur.overlay ]; }
          ({ pkgs, ... }:
            let
              nur-no-pkgs = import nur {
                nurpkgs = import nixpkgs { inherit system; };
              };
            in {
              imports = [ nur-no-pkgs.repos.iopq.modules.xraya  ];
              services.xraya.enable = true;
            })

          impermanence.nixosModules.impermanence
          nur.nixosModules.nur

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit secrets;
            };
          }
        ];
      };
    };
  };
}
