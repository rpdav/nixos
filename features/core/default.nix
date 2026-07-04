{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.core = {pkgs, ...}: {
    ## This file contains NixOS configuration common to all hosts

    imports = [
      self.modules.generic.customOptions
      self.nixosModules.homeManager
      inputs.disko.nixosModules.disko
      self.nixosModules.nix
    ];

    environment.variables = {
      EDITOR = "nvim";
    };

    system.stateVersion = "24.05";

    # Base fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
      ];
      fontconfig.enable = true;
    };

    # Allow local users to inhibit sleep (used for some systemd user units)
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.login1.inhibit-block-shutdown" &&
            subject.isInGroup("users"))
                return polkit.Result.YES;
        });
      '';
    };

    # CLI config
    programs.bash.completion.enable = true;
    environment.enableAllTerminfo = true;

    # Time
    time.timeZone = "America/Indiana/Indianapolis";
  };
  flake.homeModules.core = {
    config,
    osConfig,
    lib,
    pkgs,
    ...
  }: let
    pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [
      self.modules.generic.customOptions
    ];

    home.stateVersion = "24.05"; # HM version I built this config around
    home.homeDirectory = osConfig.users.users.${config.home.username}.home; # This is already defined in system config

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # In system, this is in a separate packages.nix - consider matching?
    home.packages = (
      with pkgs;
        (
          [
            tree
            gdu
            fastfetch
            just
          ]
          ++ lib.lists.optionals osConfig.systemOpts.gui [
            # browsers
            brave
            tor-browser

            # extra terminals
            alacritty

            # media
            #audacity
            vlc
            bibletime

            # photos
            gimp
            pinta

            # text editors and office
            typora
            kdePackages.ghostwriter
            onlyoffice-desktopeditors

            # utilities
            gnome-calendar
          ]
        )
        ++ lib.lists.optionals osConfig.systemOpts.gui (
          with pkgs-stable; [
            jellyfin-media-player # qtwebengine-5.15.19 flagged insecure in unstable
            #bitwarden-desktop # electron 39.8.10 marked insecure even on stable
          ]
        )
    );

    # Create persistent directories
    home.persistence."${config.systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
      directories = [
        ".config/Bitwarden"
        ".config/BraveSoftware"
        ".config/GIMP"
        ".config/Nextcloud"
        ".config/onlyoffice"
        ".config/remmina"
      ];
      files = [
        ".config/ghostwriterrc"
        ".config/bluedevelglobalrc" # bluetooth
      ];
    };

    # misc programs
    programs = {
      bat.enable = true;
      autojump.enable = true;
      btop.enable = true;
      ripgrep.enable = true;
    };
    services.remmina.enable = lib.mkIf osConfig.systemOpts.gui true;

    # Theming and fonts
    # Most theming is in system config through stylix.
    fonts.fontconfig.enable = true;
    gtk.iconTheme = {
      name = osConfig.stylix.fonts.emoji.name;
      package = osConfig.stylix.fonts.emoji.package;
    };

    # session variables
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
