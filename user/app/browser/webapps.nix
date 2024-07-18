{ config, pkgs, secrets, ...}:
{
  xdg.desktopEntries.actual = {
    name = "Actual";
    exec = "${userSettings.browser} --app=https://budget.${secrets.selfhosting.domain}";

  xdg.desktopEntries.silverbullet= {
    name = "SilverBullet";
    exec = "${userSettings.browser} --app=https://notes.${secrets.selfhosting.domain}";

  xdg.desktopEntries.homeassistant= {
    name = "Home Assistant";
    exec = "${userSettings.browser} --app=https://home.${secrets.selfhosting.domain}";

  xdg.desktopEntries.nirvana= {
    name = "Nirvana";
    exec = "${userSettings.browser} --app=https://focus.nirvanahq.com";

};
