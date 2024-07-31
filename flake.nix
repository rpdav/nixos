# Generation 149
{

  description = "Zenbook config";

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, impermanence, plasma-manager, ... }@inputs:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "nixbook"; # hostname
        timezone = "America/Indiana/Indianapolis"; # select timezone
        locale = "en_US.UTF-8"; # select locale
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "ryan"; # username
        name = "Ryan"; # name/identifier
        configDir = "~/.nixops"; # absolute path of the local repo
        theme = "io"; # selcted theme from my themes directory (./themes/)
        wm = "kde"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
        # window manager type (hyprland or x11) translator
        wmType = if (wm == "cinnamon") then "x11" else "wayland";
        browser = "firefox"; # Default browser; must select one from ./user/app/browser/
        term = ""; # Default terminal command;
        font = "Intel One Mono"; # Selected font
        fontPkg = pkgs.intel-one-mono; # Font package
        editor = "vim"; # Default editor;
      };

      # ----- MODULE OVERRIDES ----- #

      lib = nixpkgs.lib;
      pkgs-stable = nixpkgs-stable.legacyPackages.${systemSettings.system};
      pkgs = nixpkgs.legacyPackages.${systemSettings.system};
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

    in rec {
    nixosConfigurations = {
      nixbook = nixpkgs.lib.nixosSystem {
        system = systemSettings.system;
        specialArgs = { 
          inherit pkgs-stable;
          inherit systemSettings;
          inherit userSettings;
          inherit secrets;
        };
        modules = [

          ./system/configuration.nix 

          impermanence.nixosModules.impermanence

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./user/home.nix;
            home-manager.sharedModules = [ 
              plasma-manager.homeManagerModules.plasma-manager 
              impermanence.nixosModules.home-manager.impermanence
            ];
            home-manager.extraSpecialArgs = {
              inherit pkgs-stable;
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

    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";    
    };

    impermanence.url = "github:nix-community/impermanence";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

}
