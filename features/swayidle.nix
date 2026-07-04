{...}: {
  flake.homeModules.swayidle = {
    pkgs,
    osConfig,
    ...
  }: {
    services.swayidle = let
      # Lock command
      lock = "${pkgs.procps}/bin/pidof ${pkgs.hyprlock}/bin/hyprlock || TZ=${osConfig.time.timeZone} ${pkgs.hyprlock}/bin/hyprlock";
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
      inherit (osConfig.systemOpts) screenDimTimeout lockTimeout screenOffTimeout suspendTimeout;
    in {
      enable = true;
      timeouts = [
        {
          timeout = screenDimTimeout;
          command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        {
          timeout = lockTimeout - 5;
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
        }
        {
          timeout = lockTimeout;
          command = lock;
        }
        {
          timeout = screenOffTimeout;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = suspendTimeout;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
