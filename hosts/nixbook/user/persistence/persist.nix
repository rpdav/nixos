{ config, userSettings, impermanence, ... }:

{
  
  home.persistence."/persist/home/${userSettings.username}" = {
    directories = [
      "Documents"
      "Desktop"
      "Downloads"
      "Games"
      "Music"
      "Pictures"
      "projects"
      "Nextcloud"
      "nixos"
      "Videos"
      "scripts"
#      ".config" # this only seems to work in the system config
      ".gnupg"
      #".ssh"
      ".local"
      ".mozilla"
      ".steam"
      ".sword"
      ".thunderbird"
    ];
    files = [
      ".Xauthority"
    ];
    allowOther = true;
  };
}
