# Generation 97
{

  description = "My first flake!";

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, impermanence, ... }@inputs:
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

      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${systemSettings.system};
      pkgs-unstable = nixpkgs.legacyPackages.${systemSettings.system};
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    in rec {

    nixosConfigurations = {
      nixbook = nixpkgs.lib.nixosSystem {
        system = systemSettings.system;
        specialArgs = { 
          inherit pkgs-unstable;
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
            home-manager.extraSpecialArgs = {
              inherit pkgs-unstable;
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
    nixpkgs.url = "nixpkgs/nixos-24.05";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";    
    };

    impermanence.url = "github:nix-community/impermanence";
  };

}
