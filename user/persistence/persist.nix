{ config, userSettings, impermanence, ... }:

{
  {
  home.persistence."/persistent/home/${userSettings.username}" = {
    directories = [
      "testdir1"
      }
    ];
    files = [
      "testfile1"
    ];
    allowOther = true;
  };
}

}
