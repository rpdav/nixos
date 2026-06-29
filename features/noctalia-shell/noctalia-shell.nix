{
  inputs,
  self,
  ...
}: {
  flake.homeModules.noctalia-shell = {
    config,
    osConfig,
    ...
  }: {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia = {
      enable = true;
      settings = {
        bar = {
          default = {
            background_opacity = 0.75;
            capsule = true;
            center = ["date" "spacer_3" "clock"];
            end = ["bluetooth" "network" "spacer_1" "caffeine" "power_profile" "clipboard" "Tailscale" "spacer_2" "notifications" "tray"];
            margin_edge = 5;
            margin_ends = 5;
            padding = 6;
            radius = 25;
            shadow = false;
            start = ["control-center" "battery" "sysmon" "volume" "brightness" "weather"];
          };
          order = ["default" "workspaces"];
          workspaces = {
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
        #TODO integrate stylix themes
        theme = {
          builtin = "Tokyo-Night";
          community_palette = "Oxocarbon";
          mode = "dark";
          wallpaper_scheme = "m3-content";
        };
        wallpaper = {
          default = {path = config.stylix.image;};
          directory = "${self}/themes";
        };
        weather = {unit = "imperial";};
        widget = {
          Tailscale = {
            color = "error";
            command = "sudo tailscale up --reset";
            glyph = "shield-half-filled";
            right_command = "sudo tailscale up --accept-routes";
            tooltip = "L: home R: away";
            type = "custom_button";
          };
          battery = {color = "tertiary";};
          bluetooth = {color = "primary";};
          network = {color = "tertiary";};
          power_profile = {color = "secondary";};
          spacer_1 = {type = "spacer";};
          spacer_2 = {type = "spacer";};
          spacer_3 = {
            anchor = true;
            type = "spacer";
          };
          sysmon = {
            color = "secondary";
            display = "text";
            icon_color = "secondary";
          };
          tray = {drawer = true;};
          volume = {color = "primary";};
          workspaces = {
            display = "none";
            pill_scale = 0.75;
          };
        };
      };
    };
  };
}
