{
  self,
  inputs,
  ...
}: {
  flake.homeModules.core = let
  in
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }: let
      pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in {
      imports = [
        self.homeModules.opts
      ];

      home.stateVersion = "24.05"; # HM version I built this config around

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
              librewolf

              # terminals
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
          ++ [
            #TODO move these to admin module
            # nix file conversion tools
            selfpkgs.json2nix
            selfpkgs.nix2json
            selfpkgs.nix2toml
            selfpkgs.nix2yaml
            selfpkgs.toml2nix
            selfpkgs.yaml2nix

            # remote host management
            #selfpkgs.lish # this may not work because I can't pass inputs to a package

            # convenience script for nix-search-tv
            selfpkgs.nix-search-tv

            # misc
            selfpkgs.fs-diff
          ]
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

      ### below was copied from ryan/core/default. consider refactoring this.

      programs.lazydocker = {
        enable = true;
        settings = {
          gui.returnImmediately = true;
        };
      };

      # misc programs
      programs = {
        bat.enable = true;
        autojump.enable = true;
        btop.enable = true;
        ripgrep.enable = true;
      };
      services.remmina.enable = lib.mkIf osConfig.systemOpts.gui true;

      # session variables
      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
}
