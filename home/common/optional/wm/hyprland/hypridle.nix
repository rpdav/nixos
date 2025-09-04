{
  inputs,
  osConfig,
  pkgs,
  ...
}: {
  services.hypridle = {
    enable = true;
    settings = let
      lock_cmd = "${pkgs.procps}/bin/pidof ${pkgs.hyprlock}/bin/hyprlock || ${pkgs.hyprlock}/bin/hyprlock"; # Avoid starting multiple hyprlock instances.
      hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl"; # Use hyprland flake for hyprctl
      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    in {
      general = {
        inherit lock_cmd;
        before_sleep_cmd = lock_cmd;
        after_sleep_cmd = "${hyprctl} dispatch dpms on"; # turn on screen after sleep
      };
      listener = [
        # screen dim
        {
          timeout = osConfig.systemOpts.screenDimTimeout;
          on-timeout = "${brightnessctl} -s set 10";
          on-resume = "${brightnessctl} -r";
        }
        # keyboard dim
        {
          timeout = osConfig.systemOpts.screenDimTimeout;
          on-timeout = "${brightnessctl} -sd framework_laptop::kbd_backlight set 0";
          on-resume = "${brightnessctl} -rd framework_laptop::kbd_backlight";
        }
        # screen lock
        {
          timeout = osConfig.systemOpts.lockTimeout;
          on-timeout = lock_cmd;
        }
        # screen off after lock
        {
          timeout = osConfig.systemOpts.screenOffTimeout;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on && ${brightnessctl} -r";
        }
        # sleep
        {
          timeout = osConfig.systemOpts.suspendTimeout;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
