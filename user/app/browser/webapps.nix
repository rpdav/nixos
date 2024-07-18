{ config, pkgs, userSettings, secrets, ...}:

{
  xdg.desktopEntries.actual = {
    name = "Actual";
    exec = "chromium --app=https://budget.${secrets.selfhosting.domain}";
  };

  xdg.desktopEntries.silverbullet= {
    name = "SilverBullet";
    exec = "chromium --app=https://notes.${secrets.selfhosting.domain}";
  };

  xdg.desktopEntries.homeassistant= {
    name = "Home Assistant";
    exec = "chromium --app=https://home.${secrets.selfhosting.domain}";
  };

  xdg.desktopEntries.nirvana= {
    name = "Nirvana";
    exec = "chromium --app=https://focus.nirvanahq.com";
  };
}
