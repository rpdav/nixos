{ config, userSettings, ... }:

{
  
  home.persistence."/persist/home/${userSettings.username}" = {
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
      ".steam"
      ".sword"
      ".thunderbird"
      "scripts"
      "testdir1"
      "testdir2"
    ];

    files = [
      ".Xauthority"
      "testfile1"
    ];
  };

}
