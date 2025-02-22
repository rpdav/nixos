{
  lib,
  userOpts,
  systemOpts,
  inputs,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.home-manager.impermanence];

  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = {
    directories = (
      [
        ### home persistence for all systems ###
        # Apps
        ".gnupg"
        ".local"

        # System
        ".config/autostart" #TODO these are all just.desktop files - could be declared
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

        # Nix and other projects
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

      # System
      ".Xauthority"
    ];
    allowOther = true;
  };
}
