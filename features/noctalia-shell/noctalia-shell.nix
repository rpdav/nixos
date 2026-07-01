{
  inputs,
  self,
  ...
}: {
  flake.homeModules.noctalia-shell = {
    config,
    osConfig,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    imports = [
      inputs.noctalia.homeModules.default
      self.modules.homeManager.stylixNoctaliav5
    ];
    programs.noctalia = {
      enable = true;
      settings = {
        bar = {
          default = {
            background_opacity = 0.75;
            capsule = true;
            center = ["date" "spacer_3" "clock"];
            end = ["bluetooth" "network" "spacer_1" "caffeine" "power_profile" "clipboard" "tailscale" "lightmode" "spacer_2" "notifications" "tray"];
            margin_edge = 5;
            margin_ends = 5;
            padding = 6;
            radius = 25;
            shadow = false;
            start = ["control-center" "battery" "sysmon" "volume" "brightness" "weather"];
          };
          order = ["default" "workspaces"];
          workspaces = {
            capsule = true;
            capsule_padding = 10.0;
            background_opacity = 0;
            center = ["workspaces"];
            end = [];
            font_weight = 700;
            margin_edge = 0;
            padding = 0;
            position = "left";
            reserve_space = false;
            scale = 0.5;
            shadow = false;
            start = [];
            thickness = 10;
          };
        };
        calendar = {
          account = {
            nextcloud = {
              name = "Nextcloud";
              provider = "custom";
              server_url = "https://cloud.${inputs.nix-secrets.selfhosting.domain}/remote.php/dav";
              type = "caldav";
              username = "ryan";
            };
          };
          enabled = true;
        };
        control_center = {sidebar_section = "full";};
        desktop_widgets = {
          enabled = false;
          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };
          schema_version = 2;
          widget = {};
          widget_order = [];
        };
        idle = {
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = osConfig.systemOpts.lockTimeout;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = true;
              timeout = osConfig.systemOpts.suspendTimeout;
            };
            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = osConfig.systemOpts.screenOffTimeout;
            };
          };
          behavior_order = ["lock" "screen-off" "lock-and-suspend"];
        };
        location = {auto_locate = true;};
        lockscreen_widgets = {
          enabled = false;
          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };
          schema_version = 2;
          widget = {
            "lockscreen-login-box@eDP-1" = {
              box_height = 70;
              box_width = 400;
              cx = 720;
              cy = 841;
              output = "eDP-1";
              rotation = 0;
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12;
                input_opacity = 1;
                input_radius = 6;
                show_login_button = true;
              };
              type = "login_box";
            };
          };
          widget_order = ["lockscreen-login-box@eDP-1"];
        };
        osd = {
          offset_y = 20;
          position = "bottom_center";
        };
        shell = {
          niri_overview_type_to_launch_enabled = true;
          panel = {
            open_near_click_control_center = true;
            session_placement = "floating";
            session_position = "center";
            transparency_mode = "soft";
          };
          polkit_agent = true;
          screenshot = {directory = "${config.home.homeDirectory}/Pictures/Screenshots";};
          settings_show_advanced = true;
          telemetry_enabled = true;
        };
        weather = {unit = "imperial";};
        widget = {
          # left
          control-center = {};
          battery = {color = colors.green;};
          sysmon = {
            color = colors.brown;
            display = "text";
          };
          volume = {color = colors.magenta;};
          brightness = {color = colors.yellow;};
          weather = {color = colors.cyan;};
          # center
          date = {};
          spacer_3 = {
            anchor = true;
            type = "spacer";
          };
          clock = {};
          # right
          bluetooth = {color = colors.blue;};
          network = {color = colors.brown;};
          spacer_1 = {type = "spacer";};
          caffeine = {};
          power_profile = {color = colors.green;};
          clipboard = {color = colors.blue;};
          tailscale = {
            command = "sudo tailscale up --reset";
            glyph = "shield-half-filled";
            right_command = "sudo tailscale up --accept-routes";
            tooltip = "L: home R: away";
            type = "custom_button";
          };
          lightmode = {
            color = colors.yellow;
            glyph = "brightness-half";
            command = "nixos apply -y";
            right_command = "nixos apply --specialisation lightmode -y";
            tooltip = "L: dark R: light";
            type = "custom_button";
          };
          spacer_2 = {type = "spacer";};
          notifications = {};
          tray = {drawer = true;};
          # side bar
          workspaces = {
            display = "none";
            pill_scale = 0.75;
          };
        };
      };
    };
  };
}
