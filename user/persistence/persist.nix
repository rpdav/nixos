{ config, userSettings, impermanence, ... }:

{
  
  home.persistence."/persist/home/${userSettings.username}" = {
    directories = [
      "testdir1"
      "Documents"
    ];
    files = [
      "testfile1"
    ];
    allowOther = true;
  };
}
