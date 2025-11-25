{
  inputs,
  config,
  osConfig,
  pkgs,
  lib,
  outputs,
  ...
}: {
  imports = [
    ./hyprlock.nix
    ./hypridle.nix
    ./waybar
    ./wlogout
    outputs.homeManagerModules.monitors
  ];

  # packages
  home.packages = with pkgs; [
    # services
    libnotify

    # Screenshot utils
    slurp
    grim
    hyprpicker

    # Misc gui apps
    galculator
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
  services.swaync.enable = true;

  # OSD for volume and brightness
  services.swayosd = {
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

      ################
      ### PROGRAMS ###
      ################

      "$browser" = "${pkgs.firefox}/bin/firefox";
      "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
      "$menu" = "${pkgs.fuzzel}/bin/fuzzel";
      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$bar" = "${pkgs.waybar}/bin/waybar";
      "$lock" = "${pkgs.hyprlock}/bin/hyprlock";
      "$hyprshot" = "${pkgs.hyprshot}/bin/hyprshot";
      "$osdclient" = "${pkgs.swayosd}/bin/swayosd-client";

      #################
      ### AUTOSTART ###
      #################

      # Mostly using services instead of execonce
      exec-once = [
        "${pkgs.steam}/bin/steam -silent %U"
        "${pkgs.networkmanagerapplet}/bin/nm-applet"
        "${pkgs.blueman}/bin/blueman-applet"
      ];

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
        "TZ,${osConfig.time.timeZone}"
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
        kb_options = "compose:XF86AudioMedia";
      };
      gestures = {
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
        workspace_swipe_direction_lock = false;
      };

      cursor = {
        no_warps = true;
      };

      gesture = [
        "3, horizontal, workspace"
        "3, vertical, fullscreen"
        "3, vertical, mod: $mainMod, float"
      ];

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

          # Apps
          "$mainMod, return, exec, $terminal"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, B, exec, $browser"
          "$mainMod, space, exec, $menu"
          "$mainMod, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t"
          "$mainMod, C, exec, ${pkgs.cliphist}/bin/cliphist list | $menu --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
          "$mainMod, P, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a"

          # Lock and suspend
          ", XF86PowerOff, exec, ${pkgs.wlogout}/bin/wlogout"

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

          # Special workspaces
          "$mainMod, S, togglespecialworkspace, magic"

          # Switch workspaces
          "$mainMod, mouse_down, workspace, +1"
          "$mainMod, mouse_down, workspace, -1"
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

        # Window resize
        "$mainMod CTRL, h, resizeactive, -10 0"
        "$mainMod CTRL, l, resizeactive, 10 0"
        "$mainMod CTRL, k, resizeactive, 0 -10"
        "$mainMod CTRL, j, resizeactive, 0 10"
        "$mainMod CTRL SHIFT, h, resizeactive, -50 0"
        "$mainMod CTRL SHIFT, l, resizeactive, 50 0"
        "$mainMod CTRL SHIFT, k, resizeactive, 0 -50"
        "$mainMod CTRL SHIFT, j, resizeactive, 0 50"
      ];
      # Move/resize windows with mouse
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod SHIFT, mouse:272, resizewindow"
      ];

      # Audio and brightness
      bindeld = [
        ",XF86AudioRaiseVolume, Volume up, exec, $osdclient --output-volume raise"
        ",XF86AudioLowerVolume, Volume down, exec, $osdclient --output-volume lower"
        ",XF86AudioMute, Mute, exec, $osdclient --output-volume mute-toggle"
        ",XF86AudioMicMute, Mute microphone, exec, $osdclient --input-volume mute-toggle"
        ",XF86MonBrightnessUp, Brightness up, exec, $osdclient --brightness raise"
        ",XF86MonBrightnessDown, Brightness down, exec, $osdclient --brightness lower"
        "$mainMod, XF86MonBrightnessUp, Brightness max, exec, $osdclient --brightness +100"
        "$mainMod, XF86MonBrightnessDown, Brightness min, exec, $osdclient --brightness -100"
      ];
      bindd = [
        ",Caps_Lock, CAPS lock, exec, sleep 0.5 && $osdclient --caps-lock" # added 0.5 s delay to get current status
      ];
      bindld = [
        ", XF86AudioNext, Next track, exec, $osdclient --playerctl next"
        ", XF86AudioPause, Pause, exec, $osdclient --playerctl play-pause"
        ", XF86AudioPlay, Play, exec, $osdclient --playerctl play-pause"
        ", XF86AudioPrev, Previous track, exec, $osdclient --playerctl previous"
      ];

      ###############
      ### PLUGINS ###
      ###############
    };
  };
}
