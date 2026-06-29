{inputs, ...}: {
  flake.nixosModules.niri = {lib, ...}: {
    #TODO split this apart from hyperland config
    services.displayManager = {
      autoLogin.user = "ryan";
      gdm = {
        enable = true;
      };
      # if running both hyprland and niri, auto-login to niri
      defaultSession = lib.mkForce "niri";
    };
    programs.niri.enable = true;

    # needed for noctalia battery widget
    services.upower.enable = true;
  };
  flake.homeModules.niri = {
    pkgs,
    config,
    ...
  }: let
  in {
    imports = [
      inputs.niri-flake.homeModules.config
      inputs.niri-flake.homeModules.stylix
    ];

    programs.niri = {
      package = pkgs.niri; # Don't use package from niri-flake
      settings = {
        input = {
          power-key-handling.enable = false; # power key triggers session menu
          keyboard.xkb.layout = "us";
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
        };
        # outputs = {}; # replace this with monitors function
        layout = {
          gaps = 5;
          focus-ring.enable = false;
          default-column-width.proportion = 1. / 2.;
          preset-column-widths = [
            {proportion = 1. / 3.;}
            {proportion = 1. / 2.;}
            {proportion = 2. / 3.;}
          ];
          struts = {
            left = 5;
            right = 5;
          };
          border = {
            enable = true;
            width = 2;
            # verify colors from stylix
          };
          shadow = {
            enable = true;
            softness = 30;
            spread = 5;
            offset.x = 0;
            offset.y = 5;
            # verify colors from stylix
          };
          background-color = "transparent";
        };
        spawn-at-startup = [
          {argv = ["${config.programs.noctalia.package}/bin/noctalia"];}
          {argv = ["${pkgs.steam}/bin/steam" "-silent" "%U"];} # seems to have trouble finding xwayland
        ];
        prefer-no-csd = true;
        layer-rules = [
          {
            # wallpaper in background
            place-within-backdrop = true;
          }
          {
            matches = [{namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";}];
            # disable blur so noctalia elements can be transparent
            background-effect.blur = false;
          }
        ];
        window-rules = [
          {
            # Round all corners
            geometry-corner-radius = {
              top-left = 12.;
              top-right = 12.;
              bottom-left = 12.;
              bottom-right = 12.;
            };
            clip-to-geometry = true;
          }
          {
            # Open firefox maximized
            matches = [{app-id = "firefox";}];
            open-maximized = true;
          }
          {
            # Float Noctalia Settings
            matches = [{app-id = "dev.noctalia.Noctalia.Settings";}];
            open-floating = true;
            default-column-width.proportion = 2. / 3.;
            default-window-height.proportion = 0.75;
            default-floating-position = {
              x = 0;
              y = 100;
              relative-to = "top";
            };
          }
          {
            # Float blueman applet
            matches = [{app-id = ".blueman-manager-wrapped";}];
            open-floating = true;
            default-column-width.proportion = 1. / 3.;
            default-window-height.proportion = 0.5;
            default-floating-position = {
              x = 10;
              y = 10;
              relative-to = "top-right";
            };
          }
          {
            # Float volume control
            matches = [{app-id = "org.pulseaudio.pavucontrol";}];
            open-floating = true;
            default-column-width.proportion = 1. / 3.;
            default-window-height.proportion = 0.5;
            default-floating-position = {
              x = 200;
              y = 10;
              relative-to = "top-right";
            };
          }
        ];
        binds = let
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          noctalia = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia";
        in {
          # Misc
          "Mod+Shift+Slash".action.show-hotkey-overlay = [];
          "Mod+O" = {
            action.toggle-overview = [];
            repeat = false;
          };
          "Mod+Q" = {
            action.close-window = [];
            repeat = false;
          };

          # Launch programs
          "Mod+Return" = {
            action.spawn = ["${pkgs.kitty}/bin/kitty"];
            hotkey-overlay.title = "Open a Terminal: kitty";
          };
          "Mod+Space" = {
            action.spawn-sh = ["${noctalia} msg panel-open launcher"];
            hotkey-overlay.title = "Open Launcher";
          };
          "Mod+B" = {
            action.spawn = ["${pkgs.firefox}/bin/firefox"];
            hotkey-overlay.title = "Open a Browser: firefox";
          };

          "XF86AudioRaiseVolume" = {
            action.spawn-sh = ["${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"];
            #action.spawn-sh = ["${swayosdBin} --output-volume raise"];
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            action.spawn-sh = ["${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-"];
            #action.spawn-sh = ["${swayosdBin} --output-volume lower"];
            allow-when-locked = true;
          };
          "XF86AudioMute" = {
            action.spawn-sh = ["${wpctl} set-volume @DEFAULT_AUDIO_SINK@ toggle"];
            #action.spawn-sh = ["${swayosdBin} --output-volume mute-toggle"];
            allow-when-locked = true;
          };
          "Mod+XF86AudioRaiseVolume" = {
            action.spawn-sh = ["${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 1.0"];
            allow-when-locked = true;
          };
          "Mod+XF86AudioLowerVolume" = {
            action.spawn-sh = ["${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.25"];
            allow-when-locked = true;
          };
          "XF86AudioPlay" = {
            action.spawn-sh = ["${playerctl} play-pause"];
            allow-when-locked = true;
          };
          "XF86AudioPrev" = {
            action.spawn-sh = ["${playerctl} previous"];
            allow-when-locked = true;
          };
          "XF86AudioNext" = {
            action.spawn-sh = ["${playerctl} next"];
            allow-when-locked = true;
          };

          # Brightnesss
          "XF86MonBrightnessUp" = {
            action.spawn-sh = ["${brightnessctl} --class=backlight set +10%"];
            #action.spawn-sh = ["${swayosdBin} --brightness raise"];
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            action.spawn-sh = ["${brightnessctl} --class=backlight set +10%-"];
            #action.spawn-sh = ["${swayosdBin} --brightness lower"];
            allow-when-locked = true;
          };

          # Focus Windows
          "Mod+H".action.focus-column-left = [];
          "Mod+J".action.focus-window-or-workspace-down = [];
          "Mod+K".action.focus-window-or-workspace-up = [];
          "Mod+L".action.focus-column-right = [];
          "Mod+Home".action.focus-column-first = [];
          "Mod+End".action.focus-column-last = [];

          # Move Windows
          "Mod+Shift+H".action.move-column-left = [];
          "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [];
          "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [];
          "Mod+Shift+L".action.move-column-right = [];
          "Mod+Shift+Home".action.move-column-to-first = [];
          "Mod+Shift+End".action.move-column-to-last = [];

          # Move Workspaces
          "Mod+Shift+U".action.move-workspace-down = [];
          "Mod+Shift+I".action.move-workspace-up = [];

          # Focus Monitors
          "Mod+Ctrl+H".action.focus-monitor-left = [];
          "Mod+Ctrl+J".action.focus-monitor-down = [];
          "Mod+Ctrl+K".action.focus-monitor-up = [];
          "Mod+Ctrl+L".action.focus-monitor-right = [];

          # Move to Monitors
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

          # Mouse and Focus
          "Mod+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-workspace-down = [];
          };
          "Mod+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-workspace-up = [];
          };
          "Mod+WheelScrollRight".action.focus-column-right = [];
          "Mod+WheelScrollLeft".action.focus-column-left = [];
          "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
          "Mod+Shift+WheelScrollUp".action.focus-column-left = [];

          # Workspaces
          "Mod+1".action.focus-workspace = 1; #TODO make a function for this?
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          # Column Movements
          "Mod+BracketLeft".action.consume-or-expel-window-left = [];
          "Mod+BracketRight".action.consume-or-expel-window-right = [];
          "Mod+Comma".action.consume-window-into-column = [];
          "Mod+Period".action.expel-window-from-column = [];

          # Window resize
          "Mod+R".action.switch-preset-column-width = [];
          "Mod+Ctrl+Shift+R".action.switch-preset-window-height = [];
          "Mod+Minus".action.set-column-width = ["-10%"];
          "Mod+Equal".action.set-column-width = ["+10%"];
          "Mod+Shift+Minus".action.set-window-height = ["-10%"];
          "Mod+Shift+Equal".action.set-window-height = ["+10%"];

          # Maximize or float windows
          "Mod+F".action.maximize-column = [];
          "Mod+Shift+F".action.fullscreen-window = [];
          "Mod+M".action.maximize-window-to-edges = [];
          "Mod+V".action.toggle-window-floating = [];
          "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];

          # Escaping and closing
          "Super+Alt+L" = {
            action.spawn-sh = ["${noctalia} msg session lock"];
            hotkey-overlay.title = "Lock the Screen";
          };
          "XF86AudioMedia".action.spawn-sh = ["${noctalia} msg settings-toggle"];
          "XF86PowerOff".action.spawn-sh = ["${noctalia} msg panel-toggle session"];
          "Mod+Shift+P".action.power-off-monitors = [];
          "Mod+Shift+E".action.quit = [];
          "Ctrl+Alt+Delete".action.quit = [];
          "Mod+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = [];
          };
        };
      };
    };
  };
}
