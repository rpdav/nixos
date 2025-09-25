{
  osConfig,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    font-awesome
  ];

  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = let
      timezone = osConfig.time.timeZone;
      red = "#${config.lib.stylix.colors.red}";
    in {
      topbar = {
        layer = "top";
        position = "top";
        modules-left = [
          "custom/divider"
          "custom/power"
          "custom/divider"
          "hyprland/workspaces"
          "custom/workspace-divider"
          "battery"
          "custom/left-divider"
          "temperature"
          "custom/left-divider"
          "cpu"
        ];
        modules-center = [
          "custom/left-divider"
          "clock#1"
          "custom/left-divider"
          "clock#2"
          "custom/right-divider"
          "clock#3"
          "custom/right-divider"
        ];
        modules-right = [
          "pulseaudio"
          "custom/right-divider"
          "backlight"
          "custom/right-divider"
          "custom/weather"
          "custom/right-divider"
          "idle_inhibitor"
          "custom/divider"
          "power-profiles-daemon"
          "custom/divider"
          "tray"
          "custom/divider"
          "custom/notifications"
          "custom/divider"
        ];
        "custom/weather" = {
          format = "{}°";
          tooltip = true;
          interval = 3600;
          exec = "${pkgs.wttrbar}/bin/wttrbar --fahrenheit --mph --nerd --location Indianapolis";
          return-type = "json";
        };
        temperature = {
          critical-threshold = 80;
          thermal-zone = 1;
          format = " {temperatureC}°C";
        };
        "custom/notifications" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='${red}'></span> ";
            none = " ";
            dnd-notification = " <span foreground='${red}'></span> ";
            dnd-none = " ";
            inhibited-notification = " <span foreground='${red}'></span>";
            inhibited-none = " ";
            dnd-inhibited-notification = " <span foreground='${red}'><sup></sup></span>";
            dnd-inhibited-none = " ";
          };
          return-type = "json";
          exec-if = "which ${pkgs.swaynotificationcenter}/bin/swaync-client";
          exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
          on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t";
          on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d";
          escape = true;
        };
        "custom/power" = {
          format = " ";
          tooltip = false;
          on-click = "${pkgs.wlogout}/bin/wlogout";
        };
        memory = {
          format = "  {}%";
          interval = 5;
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {icon} {capacity}%";
          format-icons = [" " " " " " " " " "];
          states = {
            warning = 30;
            critical = 15;
          };
        };
        backlight = {
          format = "{icon}{percent}%";
          format-icons = [" " " " " " " " " " " " " " " " " "];
        };
        "clock#1" = {
          inherit timezone;
          format = "{:%a}";
          tooltip = false;
        };
        "clock#2" = {
          inherit timezone;
          format = "{:%I:%M %p}";
          on-click = "${pkgs.gnome-calendar}/bin/gnome-calendar";
          tooltip = false;
        };
        "clock#3" = {
          inherit timezone;
          format = "{:%m-%d}";
          tooltip = false;
        };
        power-profiles-daemon = {
          format = "{icon} ";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶 ";
            deactivated = "󰾫 ";
          };
        };
        cpu = {
          format = " {usage:2}%";
          interval = 5;
          menu = "on-click";
          menu-file = ./cpu_menu.xml;
          menu-actions = {
            btop = "${pkgs.kitty}/bin/kitty -o confirm_os_window_close=0 ${pkgs.btop}/bin/btop";
            systemctl-tui = "${pkgs.kitty}/bin/kitty -o confirm_os_window_close=0 ${pkgs.systemctl-tui}/bin/systemctl-tui";
          };
        };
        "custom/left-divider" = {
          format = "//";
          tooltip = false;
        };
        "custom/divider" = {
          format = " ";
          tooltip = false;
        };
        "custom/right-divider" = {
          format = "\\\\";
          tooltip = false;
        };
        "custom/workspace-divider" = {
          format = "//";
          tooltip = false;
        };
        disk = {
          format = " {percentage_used:2}%";
          interval = 5;
          path = "/";
          menu = "on-click";
          menu-file = ./disk_menu.xml;
          menu-actions = {
            btrfs = "${pkgs.btrfs-assistant}/bin/btrfs-assistant-launcher";
            root = "${pkgs.kitty}/bin/kitty -o confirm_os_window_close=0 ${pkgs.dua}/bin/dua i /";
            home = "${pkgs.kitty}/bin/kitty -o confirm_os_window_close=0 ${pkgs.dua}/bin/dua i /home";
            persist = "${pkgs.kitty}/bin/kitty -o confirm_os_window_close=0 ${pkgs.dua}/bin/dua i /persist";
          };
        };
        "hyprland/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
          format = "{name}";
          warp-on-scroll = false;
        };
        pulseaudio = {
          format = "{icon} {volume:2}%";
          format-bluetooth = "{icon} {volume}% ";
          format-icons = {
            default = [" " " "];
            headphones = " ";
          };
          format-muted = "MUTE";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          scroll-step = 5;
        };
        tray = {
          icon-size = 15;
          spacing = 5;
        };
      };
    };
    style = let
      weatherYellow = ''
        #custom-weather.clear,
        #custom-weather.sunny
      '';
      weatherBlue = ''
        #custom-weather.mist,
        #custom-weather.patchy_rain_possible,
        #custom-weather.patchy_light_drizzle,
        #custom-weather.light_drizzle,
        #custom-weather.thundery_outbreaks_possible,
        #custom-weather.patchy_light_rain,
        #custom-weather.light_rain,
        #custom-weather.moderate_rain_at_times,
        #custom-weather.moderate_rain,
        #custom-weather.heavy_rain_at_times,
        #custom-weather.heavy_rain,
        #custom-weather.light_rain_shower,
        #custom-weather.moderate_or_heavy_rain_shower,
        #custom-weather.torrential_rain_shower,
        #custom-weather.patchy_light_rain_with_thunder,
        #custom-weather.moderate_or_heavy_rain_with_thunder
      '';
    in ''
      window#waybar, tooltip {
          color: @base05;
          background: alpha(@base00, 1.000000);
      }

      tooltip {
          border-color: @base0D;
      }

      window#waybar {
      	background: @base02;
      	color: @base05;
      }

      #custom-right-divider,
      #custom-left-divider {
        color: @base01;
        font-weight: bolder;
        padding: 0 8px;
      }

      #custom-workspace-divider {
        color: @base01;
        font-weight: bolder;
        padding: 0 8 0 0px;
      }

      #custom-notification {
        font-family: "NotoSansMono Nerd Font";
      }

      #custom-power,
      #workspaces,
      #clock.1,
      #clock.2,
      #clock.3,
      #backlight,
      #power-profiles-daemon,
      #idle_inhibitor,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #disk,
      #custom-right-divider,
      #custom-left-divider,
      #custom-divider,
      #custom-workspace-divider,
      #custom-notifications,
      #custom-weather,
      #temperature,
      #tray {
      	background: @base02;
      }
      #custom-weather {
        padding: 0 0 0 3px;
      }
      ${weatherYellow} {
              color: @base0A;
      }
      ${weatherBlue} {
              color: @base0D;
      }
      #workspaces button {
      	color: @base04;
        padding: 0 8px;
      }
      #workspaces button.active {
      	color: @base0D;
              background: @base00;
      }
      #workspaces button:hover {
      	background: @base01;
      }
      #idle_inhibitor.deactivated {
              color: @base04;
      }
      #idle_inhibitor.activated {
              color: @base05;
      }
      #power-profiles-daemon {
      	color: @base0A;
      }
      #power-profiles-daemon.performance {
              color: @base0A;
      }
      #power-profiles-daemon.balanced {
      	color: @base0D;
      }
      #power-profiles-daemon.power-saver {
              color: @base0B;
      }
      #pulseaudio {
      	color: @base0B;
      }
      #backlight {
      	color: @base0A;
      }
      #memory {
      	color: @base0E;
      }
      #cpu {
      	color: @base0C;
      }
      #disk {
      	color: @base0D;
      }
      #temperature {
        color: @base0A;
      }
      #temperature.critical {
        color: @base08;
      }
      #battery {
      	color: @base0B;
      }
      #battery.warning {
      	color: @base09;
      }
      #battery.critical {
      	color: @base08;
      }
    '';
  };
}
