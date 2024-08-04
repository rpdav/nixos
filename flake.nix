# Generation 172
{

  description = "Zenbook config";

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, home-manager-unstable, home-manager-stable, impermanence, plasma-manager, ... }@inputs:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        timezone = "America/Indiana/Indianapolis"; # select timezone
        locale = "en_US.UTF-8"; # select locale
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "ryan"; # username
        name = "Ryan"; # name/identifier
        wm = "kde"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
        # window manager type (hyprland or x11) translator
        wmType = if (wm == "cinnamon") then "x11" else "wayland";
        browser = "firefox"; # Default browser; must select one from ./user/app/browser/
        term = "kitty"; # Default terminal command;
        editor = "vim"; # Default editor;
      };

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
          inherit systemSettings;
          inherit userSettings;
          inherit secrets;
        };
        modules = [

          ./nixbook/system/configuration.nix 

          impermanence.nixosModules.impermanence

          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${userSettings.username} = import ./nixbook/user/home.nix;
            home-manager.sharedModules = [ 
              plasma-manager.homeManagerModules.plasma-manager 
              impermanence.nixosModules.home-manager.impermanence
            ];
            home-manager.extraSpecialArgs = {
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
              inherit systemSettings;
              inherit userSettings;
              inherit secrets;
            };
          }
        ];
      };
    };
  };

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";    
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";    
    };

    impermanence.url = "github:nix-community/impermanence";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };
  };

}
