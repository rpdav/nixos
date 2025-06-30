{
  config,
  pkgs,
  lib,
  ...
}: {
  # Temporary config
  #  home.packages = with pkgs; [
  #    hypridle
  #  ];
  #
  #  home.file.".config/hypr/hypridle.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/nixos/home/ryan/common/optional/wm/hyprland/hypridle.conf";

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        # screen dim
        {
          timeout = config.systemOpts.screenDimTimeout;
          on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r"; # monitor backlight restore.
        }
        # keyboard dim
        {
          timeout = config.systemOpts.screenDimTimeout;
          on-timeout = "brightnessctl -sd framework_laptop::kbd_backlight set 0"; # turn off keyboard backlight.
          on-resume = "brightnessctl -rd framework_laptop::kbd_backlight"; # turn on keyboard backlight.
        }
        # screen lock
        {
          timeout = config.systemOpts.lockTimeout;
          on-timeout = "hyprlock"; # lock screen when timeout has passed
        }
        # screen off after lock
        {
          timeout = config.systemOpts.screenOffTimeout;
          on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; # screen on when activity is detected after timeout has fired.
        }
        # sleep
        {
          timeout = config.systemOpts.suspendTimeout;
          on-timeout = "systemctl suspend"; # suspend pc
        }
      ];
    };
  };
}
