{
  inputs,
  config,
  pkgs,
  ...
}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof ${pkgs.hyprlock}/bin/hyprlock || ${pkgs.hyprlock}/bin/hyprlock"; # avoid starting multiple hyprlock instances.
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        # screen dim
        {
          timeout = config.systemOpts.screenDimTimeout;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        # keyboard dim
        {
          timeout = config.systemOpts.screenDimTimeout;
          on-timeout = "i${pkgs.brightnessctl}/bin/brightnessctl -sd framework_laptop::kbd_backlight set 0";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd framework_laptop::kbd_backlight";
        }
        # screen lock
        {
          timeout = config.systemOpts.lockTimeout;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        # screen off after lock
        {
          timeout = config.systemOpts.screenOffTimeout;
          on-timeout = "${inputs.hyprland.packages."${pkgs.system}".hyprland}/bin/hyprctl dispatch dpms off"; # use hyprctl from hyprland flake
          on-resume = "${inputs.hyprland.packages."${pkgs.system}".hyprland}/bin/hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        # sleep
        {
          timeout = config.systemOpts.suspendTimeout;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
