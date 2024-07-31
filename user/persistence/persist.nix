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
    ];
    files = [
      "testfile1"
    ];
    allowOther = true;
  };
}
