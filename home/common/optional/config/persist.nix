{
  lib,
  config,
  osConfig,
  inputs,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  imports = [inputs.impermanence.nixosModules.home-manager.impermanence];

  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
    directories = (
      [
        ### home persistence for all systems ###
        # Apps
        ".gnupg"
        ".local"

        # System
        ".config/autostart" #TODO these are all just.desktop files - could be declared
        ".cache"
      ]
      ++ lib.lists.optionals systemOpts.gui [
        ### additional home persistence for gui systems ###
        # Data folders
        "Documents"
        "Pictures"
        "Desktop"
        "Games"
        "Music"
        "Nextcloud"
        "Videos"
        "Downloads"

        # Nix and other projects on main system
        "nixos"
        "nix-secrets"
        "projects"

        # System
        ".config/freerdp"
        ".config/pulse"
      ]
    );
    files = [
      ### Home file persistence for gui systems ###
    ];
    allowOther = true;
  };
}
