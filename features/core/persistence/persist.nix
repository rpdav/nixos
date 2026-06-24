{inputs, ...}: {
  flake.nixosModules.core = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];
    programs.fuse.userAllowOther = true;

    environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
      files = [
        "/etc/adjtime"
        "/etc/machine-id"
      ];
    };

    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after reboot
      Defaults lecture = never
    '';
  };
  flake.homeModules.core = {
    lib,
    config,
    osConfig,
    ...
  }: let
    inherit (osConfig) systemOpts;
  in {
    home.persistence."${systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
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
          "hosts" # files for reinstalling/restoring hosts
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
    };
  };
}
