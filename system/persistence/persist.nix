{ config, lib, secrets, ... }:

{
  
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
    adjtime.source = "/persist/etc/adjtime";
  };

  environment.persistence."/persist" = {
    enable = true;  # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/etc/wireguard"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
#      "/var/lib/sddm" # something to do with KDE
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      "/etc/.updated" #systemd file with timestamp for when it was updated
      "/var/.updated" #systemd file with timestamp for when it was updated
    ];
  ## User persistence is here since I couldn't get it to work in home-manager
    users.ryan = {
      directories = [
        ".config"
        "Desktop"
        "Downloads"
        "Games"
        "Music"
        "Pictures"
        "projects"
        "Documents"
        "Nextcloud"
        "Videos"
        ".gnupg"
        ".ssh"
        ".nixops"
        ".local"
        ".mozilla"
        ".thunderbird"
        "scripts"
#        {
#          directory = ".local/share/Steam";
#          method = "symlink";
#        };
      ];
      files = [
        ".Xauthority"
      ];
    };
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after reboot
    Defaults lecture = never
    '';
    
}
