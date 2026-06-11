{
  config,
  osConfig,
  lib,
  configLib,
  secrets,
  pkgs,
  nixpkgs-stable,
  ...
}: let
  pkgs-stable = nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    (configLib.relativeToRoot "vars")
    ./backup.nix
    ./bash.nix
    ./persist.nix
    ./sops.nix
    ./starship.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
          bitwarden-desktop
          gnome-calendar
        ]
      )
      ++ lib.lists.optionals osConfig.systemOpts.gui (
        with pkgs-stable; [
          jellyfin-media-player # qtwebengine-5.15.19 flagged insecure in unstable
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
    ];
    files = [
      ".config/ghostwriterrc"
      ".config/bluedevelglobalrc" # bluetooth
    ];
  };

  # theming
  gtk.gtk4.theme = config.gtk.theme;
}
