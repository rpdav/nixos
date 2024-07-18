{ config, pkgs, userSettings, secrets, ...}:

{
  xdg.desktopEntries.actual = {
    name = "Actual";
    exec = "chromium --app=https://budget.${secrets.selfhosting.domain}";
    icon = "/home/${userSettings.username}/.local/share/icons/actual.png";
  };

  xdg.desktopEntries.silverbullet= {
    name = "SilverBullet";
    exec = "chromium --app=https://notes.${secrets.selfhosting.domain}";
    icon = "/home/${userSettings.username}/.local/share/icons/silverbullet.jpg";
  };

  xdg.desktopEntries.homeassistant= {
    name = "Home Assistant";
    exec = "chromium --app=https://home.${secrets.selfhosting.domain}";
    icon = "/home/${userSettings.username}/.local/share/icons/homeassistant.png";
  };

  xdg.desktopEntries.nirvana= {
    name = "Nirvana";
    exec = "chromium --app=https://focus.nirvanahq.com";
    icon = "/home/${userSettings.username}/.local/share/icons/nirvana.png";
  };
}
