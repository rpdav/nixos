{inputs, ...}: {
  flake.nixosModules.niri = {
    lib,
    pkgs,
    ...
  }: {
    # Override hyprland auto-login while testing niri
    services.displayManager.autoLogin.enable = lib.mkForce false;

    programs.niri.enable = true; #TODO do I want to switch to the niri-flake package?
    # System level config for swaylock

    # Temporary simple packages while testing out imperative niri.kdl
    environment.systemPackages = with pkgs; [
      brightnessctl
      playerctl
      swayosd
      networkmanagerapplet
      noctalia-shell
    ];
  };
  flake.homeModules.niri = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
  in {
    imports = [
      inputs.niri-flake.homeModules.config
      inputs.niri-flake.homeModules.stylix
    ];
    services.polkit-gnome.enable = true;
    home.packages = with pkgs; [
      swaybg # wallpaper; replace with noctalia?
    ];

    programs.niri = {
      package = pkgs.niri; # Don't use package from niri-flake
      settings = {
        input = {
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
        };
        spawn-at-startup = [
          {argv = ["${pkgs.waybar}/bin/waybar"];}
          {argv = ["${pkgs.steam}/bin/steam" "-silent" "%U"];}
          {argv = ["${pkgs.blueman}/bin/blueman-applet"];}
          {argv = ["${pkgs.networkmanagerapplet}/bin/nm-applet"];}
          # Need to make this rerun whenever wallpaper changes
          {argv = ["${pkgs.swaybg}/bin/swaybg" "${osConfig.stylix.image}"];}
        ];
        prefer-no-csd = true;
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
          swayosdBin = "${pkgs.swayosd}/bin/swayosd-client";
          lockCmd = "TZ=${osConfig.time.timeZone} ${pkgs.hyprlock}/bin/hyprlock";
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
            action.spawn = ["${pkgs.fuzzel}/bin/fuzzel"];
            hotkey-overlay.title = "Open Launcher";
          };
          "Mod+B" = {
            action.spawn = ["${pkgs.firefox}/bin/firefox"];
            hotkey-overlay.title = "Open a Browser: firefox";
          };

          # Media binds with swayosd
          "Caps_Lock" = {
            action.spawn-sh = ["sleep 0.1 && ${swayosdBin} --caps-lock"];
            allow-when-locked = true;
          };
          "XF86AudioRaiseVolume" = {
            action.spawn-sh = ["${swayosdBin} --output-volume raise"];
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            action.spawn-sh = ["${swayosdBin} --output-volume lower"];
            allow-when-locked = true;
          };
          "XF86AudioMute" = {
            action.spawn-sh = ["${swayosdBin} --output-volume mute-toggle"];
            allow-when-locked = true;
          };
          "Mod+XF86AudioRaiseVolume" = {
            action.spawn-sh = ["${swayosdBin} --output-volume 100"];
            allow-when-locked = true;
          };
          "Mod+XF86AudioLowerVolume" = {
            action.spawn-sh = ["${swayosdBin} --output-volume 0&& ${swayosdBin} --output-volume 25"];
            allow-when-locked = true;
          };
          "XF86AudioPlay" = {
            action.spawn-sh = ["${swayosdBin} --playerctl play-pause"];
            allow-when-locked = true;
          };
          "XF86AudioPrev" = {
            action.spawn-sh = ["${swayosdBin} --playerctl previous"];
            allow-when-locked = true;
          };
          "XF86AudioNext" = {
            action.spawn-sh = ["${swayosdBin} --playerctl next"];
            allow-when-locked = true;
          };

          # Brightnesss
          "XF86MonBrightnessUp" = {
            action.spawn-sh = ["${swayosdBin} --brightness raise"];
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            action.spawn-sh = ["${swayosdBin} --brightness lower"];
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
            action.spawn-sh = ["${lockCmd}"];
            hotkey-overlay.title = "Lock the Screen: hyprlock";
          };
          "XF86AudioMedia".action.spawn = ["${pkgs.wlogout}/bin/wlogout"];
          "XF86PowerOff".action.spawn = ["${pkgs.wlogout}/bin/wlogout"]; # This doesn't seem to work - still puts computer to sleep
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
