{ config, userSettings, impermanence, ... }:

{
  
  home.persistence."/persist/home/${userSettings.username}" = {
    directories = [
      "testdir1"
    ];
    files = [
      "testfile1"
    ];
  };
}
