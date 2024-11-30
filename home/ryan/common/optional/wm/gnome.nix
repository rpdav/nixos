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
        "dash-to-panel@jderose9.github.com"
        "trayIconsReloaded@selfmade.pl"
        "arcmenu@arcmenu.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "status-icons@gnome-shell-extensions.gcampax.github.com"
        "window-list@gnome-shell-extensions.gcampax.github.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
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
