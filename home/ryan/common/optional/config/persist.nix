{userSettings, ...}: {
  home.persistence."/persist/home/${userSettings.username}" = {
    directories = [
      # Personal folders
      "Documents"
      "Desktop"
      "Downloads"
      "Games"
      "Music"
      "Pictures"
      "Nextcloud"
      "Videos"

      # Nix and Ansible
      "nixos"
      "nix-secrets"
      "projects"

      # Apps
      ".gnupg"
      ".ssh"
      ".local"
      ".mozilla"
      ".steam"
      ".sword"
      ".thunderbird"
      ".config/borg"
      ".config/BraveSoftware"
      ".config/chromium"
      ".config/GIMP"
      ".config/'Moonlight Game Streaming Project'"
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
      ".config/autostart"
      ".config/freerdp"
      ".config/pulse"
      ".config/rclone" #TODO maybe this can be added to config? It's just a couple key/value pairs.
      ".config/sops"
      #".config/systemd" #this folder must be persisted through the system config
    ];
    files = [
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
