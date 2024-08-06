{ config, userSettings, impermanence, ... }:

{
  
  home.persistence."/persist/home/${userSettings.username}" = {
    directories = [
      "testdir1"
      "Documents"
      "Desktop"
      "Downloads"
      "Games"
      "Music"
      "Pictures"
      "projects"
      "Nextcloud"
      "Videos"
      "scripts"
#      ".config" # this only seems to work in the system config
      ".gnupg"
      ".ssh"
      ".nixops"
      ".local"
      ".mozilla"
      ".steam"
      ".sword"
      ".thunderbird"
    ];
    files = [
      "testfile1"
      ".Xauthority"
    ];
    allowOther = true;
  };
}