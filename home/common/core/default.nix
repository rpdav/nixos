{
  config,
  osConfig,
  lib,
  configLib,
  pkgs,
  inputs,
  ...
}: let
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    (configLib.relativeToRoot "vars")
    ./backup.nix
    ./bash.nix
    ./persist.nix
    ./sops.nix
    ./starship.nix
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
          #bitwarden-desktop # electron 39.8.10 marked insecure
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
}
