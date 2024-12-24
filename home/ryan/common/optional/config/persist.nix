{
  lib,
  userOpts,
  systemOpts,
  inputs,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.home-manager.impermanence];
  #TODO break this into gui and non-gui lists
  home.persistence."/persist/home/${userOpts.username}" = {
    directories = (
      [
        ### home persistence for all systems ###
        # Data folders
        "Documents"
        "Pictures"

        # Apps
        ".gnupg"
        ".ssh"
        ".local"
        ".config/borg"
	".terminfo" # kitty config for remote hosts

        # System
        ".config/autostart"
        ".config/rclone" #TODO maybe this can be added to config? It's just a couple key/value pairs.
        ".config/sops"
        #".config/systemd" #persisting this will break HM - must be rebuilt each time. See readme.
      ]
      ++ lib.lists.optional systemOpts.gui [
        ### additional home persistence for gui systems ###
        # Data folders
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

        # Apps
        ".mozilla"
        ".steam"
        ".sword"
        ".thunderbird"
        ".config/BraveSoftware"
        ".config/chromium"
        ".config/GIMP"
        ".config/Moonlight Game Streaming Project"
        ".config/Nextcloud"
        ".config/onlyoffice"
        ".config/protonmail"
        ".config/remmina"
        ".config/unity3d" #game data

        # Gnome
        ".cache/evolution" #calendar data
        ".config/evolution" #calendar config
        ".config/goa-1.0" #dav accounts
        #".config/gtk-2.0"
        #".config/gtk-3.0"
        #".config/gtk-4.0"
        #".config/nemo"

        # KDE
        #".config/kdedefaults"
        #".config/kde.org"

        # System
        ".config/freerdp"
        ".config/pulse"
      ]
    );
    files = [
      ### Home file persistence for gui systems ###
      # Apps
      ".config/ghostwriterrc"

      # Gnome

      # KDE
      #".config/gwenviewrc"
      #".config/kactivitymanagerd-statsrc"
      #".config/konsolerc"
      #".config/konsolesshconfig"
      #".config/krdpserverrc"
      #".config/kwriterc"

      # System
      ".Xauthority"
      ".config/bluedevelglobalrc" # bluetooth
    ];
    allowOther = true;
  };
}
