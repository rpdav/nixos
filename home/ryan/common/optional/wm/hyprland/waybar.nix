{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    font-awesome
  ];

  stylix.targets.waybar.enable = false;

  # From cgbassi's config https://github.com/cjbassi/config/tree/master/.config/waybar
  programs.waybar = {
    enable = true;
    settings = {
      topbar = let
        timezone = config.systemOpts.timezone;
      in {
        layer = "top";
        position = "top";
        modules-left = [
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
          "memory"
          "custom/right-divider"
          "cpu"
          "custom/right-divider"
          "disk"
          "custom/right-divider"
          "battery"
          "custom/divider"
          "tray"
        ];
        memory = {
          format = "Mem {}%";
          interval = 5;
        };
        battery = {
          format = "{icon} {capacity}%";
          format-icons = ["   " "   " "   " "   " "   "];
          states = {
            critical = 15;
            good = 95;
            warning = 30;
          };
        };
        "clock#1" = {
          inherit timezone;
          format = "{:%a}";
          tooltip = false;
        };
        "clock#2" = {
          inherit timezone;
          format = "{:%I:%M %p}";
          tooltip = false;
        };
        "clock#3" = {
          inherit timezone;
          format = "{:%m-%d}";
          tooltip = false;
        };
        cpu = {
          format = "CPU {usage:2}%";
          interval = 5;
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
          format = "Disk {percentage_used:2}%";
          interval = 5;
          path = "/";
        };
        "hyprland/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
          format = "{name}";
          warp-on-scroll = false;
        };
        pulseaudio = {
          format = "{icon} {volume:2}%";
          format-bluetooth = "{icon}  {volume}%";
          format-icons = {
            default = ["  " "  "];
            headphones = "  ";
          };
          format-muted = "MUTE";
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";
          scroll-step = 5;
        };
        tray = {icon-size = 20;};
      };
    };
    style = ''
      * {
      	font-size: 15px;
      	font-family: FontAwesome;
      }

      window#waybar {
      	background: #292b2e;
      	color: #fdf6e3;
      }

      #custom-right-divider,
      #custom-left-divider {
      	color: #1a1a1a;
        font-weight: bolder;
        padding: 0 8px;
      }

      #workspaces,
      #clock.1,
      #clock.2,
      #clock.3,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #disk,
      #custom-right-divider,
      #custom-left-divider,
      #custom-divider,
      #tray {
      	background: #292b2e;
      }

      #workspaces button {
      	color: #fdf6e3;
      }
      #workspaces button.active {
      	color: #268bd2;
      }
      #workspaces button:hover {
      	box-shadow: inherit;
      	text-shadow: inherit;
      }
      #workspaces button:hover {
      	background: #1a1a1a;
      	border: #1a1a1a;
      }

      #pulseaudio {
      	color: #268bd2;
      }
      #memory {
      	color: #2aa198;
      }
      #cpu {
      	color: #6c71c4;
      }
      #battery {
      	color: #859900;
      }
      #disk {
      	color: #b58900;
      }
    '';
  };
}
