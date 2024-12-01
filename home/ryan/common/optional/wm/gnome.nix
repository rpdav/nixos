{ lib, pkgs, ... }:

#with lib.hm.gvariant;
{
## gtk themes to go here?

# Gnome extensions
  home.packages = with pkgs.gnomeExtensions; [
    # Extensions - must be enabled in dconf too
    tray-icons-reloaded #sys tray icons - only works in X/xwayland
    vitals
    arc-menu
    dash-to-panel #kde or windows-like bottom panel. replaces top panel
    dash-to-dock #mac-like app dock
    space-bar
    appindicator #sys tray icons
    auto-move-windows #auto launch windows on certain workspaces
    caffeine #toggle to disable auto-suspend
    clipboard-indicator
    openweather-refined
    removable-drive-menu
    quick-settings-tweaker
  ];

#dconf settings
  dconf.settings = {

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop" 
        "thunderbird.desktop" 
        "org.gnome.Nautilus.desktop" 
        "kitty.desktop" 
        "org.gnome.Calendar.desktop" 
        "org.gnome.Settings.desktop" 
      ];
      disable-user-extensions = false;
      # must be installed in home.packages above, and then enabled here
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "openweather-extension@penguin-teal.github.io"
        "space-bar@luchrioh"
      ];
    };

    "org/gnome/desktop/wm/preferences" = {
      workspace-names = [ 
        "Main"
        "Dev"
        "Media"
        "Misc"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-format = "12h";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" ];
      home = [ "<Super>e" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "kitty";
      name = "terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Shift><Control>Escape";
      command = "gnome-process-monitor";
      name = "processes";
    };

  };

}
