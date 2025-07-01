{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    font-awesome
  ];

  stylix.targets.waybar.addCss = false;

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
          format-icons = ["  " "  " "  " "  " "  "];
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
            default = [" " " "];
            headphones = " ";
          };
          format-muted = "MUTE";
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";
          scroll-step = 5;
        };
        tray = {icon-size = 20;};
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
      # Add default color schme (Catppuccin Mocha) if stylix is disabled.
      defaultColors = ''
        @define-color base00 #1e1e2e; @define-color base01 #181825;
        @define-color base02 #313244; @define-color base03 #45475a;
        @define-color base04 #585b70; @define-color base05 #cdd6f4;
        @define-color base06 #f5e0dc; @define-color base07 #b4befe;

        @define-color base08 #f38ba8; @define-color base09 #fab387;
        @define-color base0A #f9e2af; @define-color base0B #a6e3a1;
        @define-color base0C #94e2d5; @define-color base0D #89b4fa;
        @define-color base0E #cba6f7; @define-color base0F #f2cdcd;

      '';
    in
      lib.optionalString (!config.stylix.targets.waybar.enable) defaultColors
      + ''

        * {
            font-family: "Intel One Mono";
            font-size: 10pt;
        }


        window#waybar, tooltip {
            color: @base05;
        }

        tooltip {
            border-color: @base0D;
        }

        window#waybar, tooltip {
            background: alpha(@base00, 1.000000);
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
        	background: @base02;
        }

        #workspaces button {
        	color: @base04;
        }
        #workspaces button.active {
        	color: @base0D;
                background: @base00;
        }
        /*#workspaces button:hover {
        	box-shadow: inherit;
        	text-shadow: inherit;
        }*/
        #workspaces button:hover {
        	background: @base01;
        }

        #pulseaudio {
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
