{
  pkgs,
  config,
  lib,
  ...
}: let
  update-checker = pkgs.callPackage update-checker/default.nix {inherit pkgs config;};
in {
  #imports = [./update-checker];

  home.packages = with pkgs; [
    font-awesome
  ];

  # icons for update_checker
  home.file.".icons" = {
    recursive = true;
    source = update-checker/.icons;
  };

  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = let
      timezone = config.systemOpts.timezone;
    in {
      topbar = {
        layer = "top";
        position = "top";
        modules-left = [
          "custom/divider"
          "custom/power"
          "custom/divider"
          "custom/divider"
          "custom/nix-updates"
          "custom/left-divider"
          "disk"
          "custom/left-divider"
          "memory"
          "custom/left-divider"
          "cpu"
          "custom/left-divider"
          "hyprland/workspaces"
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
          "battery"
          "custom/right-divider"
          "idle_inhibitor"
          "custom/divider"
          "power-profiles-daemon"
          "custom/divider"
          "network"
          "custom/divider"
          "bluetooth"
          "custom/divider"
          "custom/notifications"
          "custom/divider"
          "tray"
          "custom/divider"
        ];
        "custom/nix-updates" = {
          exec = update-checker;
          signal = 12;
          on-click = "";
          on-click-right = "rm ~/.cache/nix-update-last-run";
          interval = 3600;
          tooltip = true;
          return-type = "json";
          format = "{} {icon}";
          format-icons = {
            default = " ";
            has-updates = "󰚰 ";
            updating = " ";
            updated = " ";
            error = " ";
          };
        };
        "custom/notifications" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span> ";
            none = " ";
            dnd-notification = " <span foreground='red'><sup></sup></span> ";
            dnd-none = " ";
            inhibited-notification = " <span foreground='red'><sup></sup></span>";
            inhibited-none = " ";
            dnd-inhibited-notification = " <span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = " ";
          };
          return-type = "json";
          exec-if = "which ${pkgs.swaynotificationcenter}/bin/swaync-client";
          exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
          on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
          escape = true;
        };
        "custom/power" = {
          format = " ";
          tooltip = false;
          menu = "on-click";
          menu-file = ./power_menu.xml;
          menu-actions = {
            shutdown = "shutdown";
            reboot = "reboot";
            suspend = "systemctl suspend";
            lock = "${pkgs.hyprlock}/bin/hyprlock";
          };
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
        bluetooth = {
          format-on = "󰂯";
          format-connected = "󰂱";
          format-disabled = "󰂲";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
          tooltip-format = "No devices connected";
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t 󰁹 {device_battery_percentage}%";
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
        network = {
          format-wifi = "󰖩 ";
          format-ethernet = " ";
          format-disconnected = "󱚼 ";
          format-disabled = "󰖪 ";
          tooltip-format = "{ipaddr} on {essid}, {signalStrength}%";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          on-click-right = "pkill nm-applet";
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
          icon-size = 20;
          spacing = 5;
        };
      };
    };
    ### COLOR GUIDE
    # Adapted from https://nix-community.github.io/stylix/styling.html
    # 00 active background
    # 01 alternate background
    # 02 inactive background
    # 03 medium background
    # 04 light background
    # 05 text
    # 06 alt text
    # 07 accent text
    # 08 error text
    # 09 urgent text
    # 0A warning text
    # 0B color1
    # 0C color2
    # 0D color3
    # 0E color4
    # 0F color5
    style = let
      # Add default colors and font if stylix is disabled.
      defaultColors = ''
        /* Catppuccin Mocha */
        @define-color base00 #1e1e2e; /* base */
        @define-color base01 #181825; /* mantle */
        @define-color base02 #313244; /* surface0 */
        @define-color base03 #45475a; /* surface1 */
        @define-color base04 #585b70; /* surface2 */
        @define-color base05 #cdd6f4; /* text */
        @define-color base06 #f5e0dc; /* rosewater */
        @define-color base07 #b4befe; /* lavendar */
        @define-color base08 #f38ba8; /* red */
        @define-color base09 #fab387; /* peach */
        @define-color base0A #f9e2af; /* yellow */
        @define-color base0B #a6e3a1; /* green */
        @define-color base0C #94e2d5; /* teal */
        @define-color base0D #89b4fa; /* blue */
        @define-color base0E #cba6f7; /* mauve */
        @define-color base0F #f2cdcd; /* flamingo */

        * {
            font-family: "monospace";
            font-size: 10px;
        }
      '';
    in
      lib.optionalString (!config.stylix.targets.waybar.enable) defaultColors
      + ''
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
        #network,
        #bluetooth,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk,
        #custom-right-divider,
        #custom-left-divider,
        #custom-divider,
        #custom-notifications,
        #custom-nix-updates,
        #tray {
        	background: @base02;
        }
        #custom-nix-updates {
                color: @base05;
        }
        #workspaces button {
        	color: @base04;
        }
        #workspaces button.active {
        	color: @base0D;
                background: @base00;
        }
        #workspaces button:hover {
        	background: @base01;
        }
        #idle_inhibitor {
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
        #bluetooth {
        	color: @base0D;
        }
        #bluetooth.disabled {
                color: @base04;
        }
        #network {
        	color: @base0E;
        }
        #network.disconnected {
                color: @base08;
        }
        #network.disabled {
                color: @base04;
        }
        #pulseaudio {
        	color: @base0B;
        }
        #backlight {
        	color: @base0F;
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
