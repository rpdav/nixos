{pkgs, ...}: {
  home.packages = with pkgs; [
    font-awesome
  ];

  stylix.targets.waybar.enable = false;

  # From cgbassi's config https://github.com/cjbassi/config/tree/master/.config/waybar
  programs.waybar = {
    enable = true;
    #    style = ''
    #
    #      * {
    #      	font-size: 15px;
    #      	font-family: FontAwesome;
    #      }
    #
    #      window#waybar {
    #      	background: #292b2e;
    #      	color: #fdf6e3;
    #      }
    #
    #      #custom-right-arrow-dark,
    #      #custom-left-arrow-dark {
    #      	color: #1a1a1a;
    #          font-size: 20px;
    #      }
    #      #custom-right-arrow-light,
    #      #custom-left-arrow-light {
    #      	color: #292b2e;
    #      	background: #1a1a1a;
    #          font-size: 20px;
    #      }
    #
    #      #workspaces,
    #      #clock.1,
    #      #clock.2,
    #      #clock.3,
    #      #pulseaudio,
    #      #memory,
    #      #cpu,
    #      #battery,
    #      #disk,
    #      #tray {
    #      	background: #1a1a1a;
    #      }
    #
    #      #workspaces button {
    #      	padding: 0 10px;
    #      	color: #fdf6e3;
    #      }
    #      #workspaces button.active {
    #      	color: #268bd2;
    #      }
    #      #workspaces button:hover {
    #      	box-shadow: inherit;
    #      	text-shadow: inherit;
    #      }
    #      #workspaces button:hover {
    #      	background: #1a1a1a;
    #      	border: #1a1a1a;
    #      	padding: 0 3px;
    #      }
    #
    #      #pulseaudio {
    #      	color: #268bd2;
    #              padding: 0 12px;
    #      }
    #      #memory {
    #      	color: #2aa198;
    #              padding: 0 10px;
    #      }
    #      #cpu {
    #      	color: #6c71c4;
    #      }
    #      #battery {
    #      	color: #859900;
    #      }
    #      #disk {
    #      	color: #b58900;
    #      }
    #
    #      #clock,
    #      #pulseaudio
    #      #memory,
    #      #cpu,
    #      #battery,
    #      #disk {
    #      	padding: 0 10px;
    #      }
    #    '';
    #    settings = {
    #      topbar = {
    #        battery = {
    #          format = "{icon} {capacity}%";
    #          format-icons = ["   " "   " "   " "   " "   "];
    #          states = {
    #            critical = 15;
    #            good = 95;
    #            warning = 30;
    #          };
    #        };
    #        "clock#1" = {
    #          format = "{:%a}";
    #          tooltip = false;
    #        };
    #        "clock#2" = {
    #          format = "{:%H:%M}";
    #          tooltip = false;
    #        };
    #        "clock#3" = {
    #          format = "{:%m-%d}";
    #          tooltip = false;
    #        };
    #        cpu = {
    #          format = "CPU {usage:2}%";
    #          interval = 5;
    #        };
    #        "custom/left-arrow-dark" = {
    #          format = "";
    #          tooltip = false;
    #        };
    #        "custom/left-arrow-light" = {
    #          format = "";
    #          tooltip = false;
    #        };
    #        "custom/right-arrow-dark" = {
    #          format = "";
    #          tooltip = false;
    #        };
    #        "custom/right-arrow-light" = {
    #          format = "";
    #          tooltip = false;
    #        };
    #        disk = {
    #          format = "Disk {percentage_used:2}%";
    #          interval = 5;
    #          path = "/";
    #        };
    #        "hyprland/workspaces" = {
    #          all-outputs = true;
    #          disable-scroll = true;
    #          format = "{name}: {icon}";
    #          format-icons = {
    #            "1" = "";
    #            "2" = "";
    #            "3" = "";
    #            "4" = "";
    #            "5" = "";
    #            default = "";
    #            focused = "";
    #            urgent = "";
    #          };
    #          warp-on-scroll = false;
    #        };
    #        layer = "top";
    #        memory = {
    #          format = "Mem {}%";
    #          interval = 5;
    #        };
    #        modules-center = ["custom/left-arrow-dark" "clock#1" "custom/left-arrow-light" "custom/left-arrow-dark" "clock#2" "custom/right-arrow-dark" "custom/right-arrow-light" "clock#3" "custom/right-arrow-dark"];
    #        modules-left = ["hyprland/workspaces" "custom/right-arrow-dark"];
    #        modules-right = ["custom/left-arrow-dark" "pulseaudio" "custom/left-arrow-light" "custom/left-arrow-dark" "memory" "custom/left-arrow-light" "custom/left-arrow-dark" "cpu" "custom/left-arrow-light" "custom/left-arrow-dark" "disk" "custom/left-arrow-light" "custom/left-arrow-dark" "battery" "tray"];
    #        position = "top";
    #        pulseaudio = {
    #          format = "{icon} {volume:2}%";
    #          format-bluetooth = "{icon}  {volume}%";
    #          format-icons = {
    #            default = ["   " "   "];
    #            headphones = "";
    #          };
    #          format-muted = "MUTE";
    #          on-click = "pamixer -t";
    #          on-click-right = "pavucontrol";
    #          scroll-step = 5;
    #        };
    #        tray = {icon-size = 20;};
    #      };
    #    };
  };
}
