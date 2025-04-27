{
  pkgs,
  systemOpts,
  userOpts,
  lib,
  ...
}: {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".cache/evolution" #calendar data
      ".config/evolution" #calendar config
      ".config/goa-1.0" #dav accounts
      #".config/gtk-2.0"
      #".config/gtk-3.0"
      #".config/gtk-4.0"
      #".config/nemo"
    ];
  };

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
        "actual.desktop"
        "silverbullet.desktop"
      ];
      disable-user-extensions = false;
      # must be installed in home.packages above, and then enabled here
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "space-bar@luchrioh"
      ];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      workspace-names = [
        "Main"
        "Term"
        "Media"
        "Misc"
      ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"];
      home = ["<Super>e"];
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

    # Disable auto brightness adjustment
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
    };
  };
}
