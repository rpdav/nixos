{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./waybar
    ./hyprlock.nix
    ./hypridle.nix
  ];

  # core utilities
  home.packages = with pkgs; [
    # services
    libnotify

    # Screenshot utils
    slurp
    grim

    # Misc gui apps
    vlc
    galculator
    gnome-calendar
    cheese
  ];

  # clipboard history
  services.cliphist.enable = true;

  # gui app privilege escallation
  services.hyprpolkitagent.enable = true;

  # launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        #TODO: integrate this with stylix?
        font = lib.mkForce "monospace:size=14";
        dpi-aware = "yes";
      };
    };
  };

  # notifications
  services.dunst = {
    enable = true;
  };

  # flash drive sys tray
  services.udiskie.enable = true;

  # Stylix overrides for hyprland
  stylix.opacity.terminal = lib.mkForce 1.0;

  wayland.windowManager.hyprland = {
    enable = true;
    # plugins break often due to version mismatches even with version pinning :(
    plugins = let
      hyprPlugins = inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system};
    in [
      hyprPlugins.hyprexpo
      hyprPlugins.hyprfocus
    ];
    settings = {
      ################
      ### MONITORS ###
      ################
      monitor = lib.flatten [
        ", preferred, auto, 1" # Default for non-defined monitors (e.g. projectors)

        # Dynamic monitor config from monitors.nix module
        (map
          (
            m: let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
              scaling = lib.strings.floatToString m.scaling;
            in "${m.name},${
              if m.enabled
              then "${resolution}, ${position}, ${scaling}"
              else "disable"
            }"
          )
          (config.monitors))
      ];

      ###################
      ### MY PROGRAMS ###
      ###################

      "$browser" = "${pkgs.firefox}/bin/firefox";
      "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
      "$menu" = "${pkgs.fuzzel}/bin/fuzzel";
      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$bar" = "${pkgs.waybar}/bin/waybar";
      "$lock" = "${pkgs.hyprlock}/bin/hyprlock";
      "$hyprshot" = "${pkgs.hyprshot}/bin/hyprshot";

      #################
      ### AUTOSTART ###
      #################

      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      env = [
        # QT app settings (stylix theming broken)
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qtct" # Default theme for stylix

        # XDG vars
        "XDG_SESSION_DESKTOP,Hyprland"

        # Miscellaneous
        "TZ,${config.systemOpts.timezone}"
      ];

      #####################
      ### LOOK AND FEEL ###
      #####################

      decoration = {
        rounding = 5;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
      };

      animations = {
        animation = "global, 1, 5, default";
      };

      #############
      ### INPUT ###
      #############

      input = {
        follow_mouse = 2;
        touchpad = {
          natural_scroll = true;
          drag_lock = 1;
        };
      };

      cursor = {
        no_warps = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
        workspace_swipe_direction_lock = false;
      };

      ###################
      ### KEYBINDINGS ###
      ###################

      "$mainMod" = "SUPER";

      bind =
        [
          # General
          "$mainMod, M, exit,"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, forcekillactive,"
          "$mainMod, V, togglefloating,"
          "$mainMod, F, fullscreen"
          #", SUPER, hyprexpo:expo, toggle"

          # Apps
          "$mainMod, return, exec, $terminal"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, B, exec, $browser"
          "$mainMod, space, exec, $menu"
          "$mainMod, C, exec, ${pkgs.cliphist}/bin/cliphist list | $menu --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"

          # Lock and suspend
          ", XF86AudioMedia, exec, $lock"
          "$mainMod, XF86AudioMedia, exec, systemctl suspend"

          # Screenshotting to clipboard
          ", PRINT, exec, $hyprshot -m output -z --clipboard-only" # Monitor
          "$mainMod, PRINT, exec, $hyprshot -m window -z --clipboard-only" # Window
          "$mainMod SHIFT, PRINT, exec, $hyprshot -m region -z --clipboard-only" # Selection

          # Window focus
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
          "ALT, Tab, cyclenext,"
          "ALT, Tab, bringactivetotop,"

          # Window movement
          "$mainMod SHIFT, h, swapwindow, l"
          "$mainMod SHIFT, l, swapwindow, r"
          "$mainMod SHIFT, k, swapwindow, u"
          "$mainMod SHIFT, j, swapwindow, d"

          # Window resize
          "$mainMod CTRL, h, resizeactive, -10 0"
          "$mainMod CTRL, l, resizeactive, 10 0"
          "$mainMod CTRL, k, resizeactive, 0 -10"
          "$mainMod CTRL, j, resizeactive, 0 10"

          # Special workspaces
          "$mainMod, S, togglespecialworkspace, magic"
        ]
        ++ (
          # Workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mainMod, code:1${toString i}, workspace, ${toString ws}"
                "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

      binde = [
        # Window movement (pt 2)
        "$mainMod SHIFT, h, moveactive, -50 0"
        "$mainMod SHIFT, l, moveactive, 50 0"
        "$mainMod SHIFT, k, moveactive, 0 -50"
        "$mainMod SHIFT, j, moveactive, 0 50"
      ];
      # Move/resize windows with mouse
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod SHIFT, mouse:272, resizewindow"
      ];

      # Audio and brightness
      bindel = [
        ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 5%-"
      ];
      bindl = [
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];

      ###############
      ### PLUGINS ###
      ###############
    };
  };
}
