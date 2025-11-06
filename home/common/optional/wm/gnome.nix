{
  pkgs,
  outputs,
  ...
}: let
  monitor1 = builtins.elemAt outputs.nixosConfigurations.nas.config.home-manager.users.ryan.monitors 0;
  monitor2 = builtins.elemAt outputs.nixosConfigurations.nas.config.home-manager.users.ryan.monitors 1;
  monitorXML = ''
    <monitors version="2">
      <configuration>
        <layoutmode>physical</layoutmode>
        <logicalmonitor>
          <x>0</x>
          <y>0</y>
          <scale>1</scale>
          <monitor>
            <monitorspec>
              <connector>HDMI-1</connector>
              <vendor>DEL</vendor>
              <product>DELL SE2422H</product>
              <serial>5GBXZN3</serial>
            </monitorspec>
            <mode>
              <width>1920</width>
              <height>1080</height>
              <rate>60.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
        <logicalmonitor>
          <x>1920</x>
          <y>0</y>
          <scale>1</scale>
          <primary>yes</primary>
          <monitor>
            <monitorspec>
              <connector>DP-3</connector>
              <vendor>ACR</vendor>
              <product>VG240Y P</product>
              <serial>0x93923d02</serial>
            </monitorspec>
            <mode>
              <width>1920</width>
              <height>1080</height>
              <rate>143.855</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      </configuration>
    </monitors>
  '';
in {
  imports = [outputs.homeManagerModules.monitors];

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

  # Gnome dconf settings
  dconf.settings = {
    # Disable sleep on AC
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";

    "org/gnome/shell" = {
      # Pinned apps
      favorite-apps = [
        "firefox.desktop"
        "thunderbird.desktop"
        "org.gnome.Nautilus.desktop"
        "kitty.desktop"
        "org.gnome.Calendar.desktop"
        "actual.desktop"
        "silverbullet.desktop"
      ];

      # Extensions
      # must be installed in home.packages above, and then enabled here
      disable-user-extensions = false;
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "space-bar@luchrioh"
      ];
    };

    # Workspaces
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      workspace-names = [
        "Work"
        "Term"
        "Media"
        "Games"
      ];
    };

    # Clock
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
    };

    # Keybinds
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
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
