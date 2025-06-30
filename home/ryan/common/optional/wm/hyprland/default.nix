{
  config,
  pkgs,
  systemOpts,
  userOpts,
  lib,
  ...
}: {
  imports = [
    ./waybar.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  # core utilities
  home.packages = with pkgs; [
    libnotify
  ];

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

  #notifications
  services.dunst = {
    enable = true;
  };

  # Stylix overrides for hyprland
  stylix.opacity.terminal = lib.mkForce 1.0;

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    settings = {
      ################
      ### MONITORS ###
      ################

      monitor = "e-DP1,preferred,auto,2";

      ###################
      ### MY PROGRAMS ###
      ###################

      "$browser" = "${pkgs.firefox}/bin/firefox";
      "$fileManager" = "${pkgs.nautilus}/bin/nautilus";
      "$menu" = "${pkgs.fuzzel}/bin/fuzzel";
      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$bar" = "${pkgs.waybar}/bin/waybar";
      "$lock" = "${pkgs.hyprlock}/bin/hyprlock";

      #################
      ### AUTOSTART ###
      #################

      exec-once = ["$bar"];

      #####################
      ### LOOK AND FEEL ###
      #####################

      decoration = {
        shadow = {
          color = "rgba(1e1e2e99)";
        };
        rounding = 5;

        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };

      general = {
        "col.active_border" = "rgb(89b4fa)";
        "col.inactive_border" = "rgb(45475a)";
        gaps_in = 5;
        gaps_out = 10;

        border_size = 2;
      };

      group = {
        groupbar = {
          "col.active" = "rgb(89b4fa)";
          "col.inactive" = "rgb(45475a)";
          text_color = "rgb(cdd6f4)";
        };
        "col.border_active" = "rgb(89b4fa)";
        "col.border_inactive" = "rgb(45475a)";
        "col.border_locked_active" = "rgb(94e2d5)";
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
          "$mainMod, return, exec, $terminal"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, forcekillactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, B, exec, $browser"
          "$mainMod, V, togglefloating,"
          "$mainMod, L, exec, $lock"
          "$mainMod, F, fullscreen"
          "$mainMod, space, exec, $menu"
          "$mainMod, P, pseudo,"
          "$mainMod, J, togglesplit,"

          # Window focus
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "ALT, Tab, cyclenext,"
          "ALT, Tab, bringactivetotop,"

          # Window resize
          "$mainMod SHIFT, left, resizeactive, -10 0"
          "$mainMod SHIFT, right, resizeactive, 10 0"
          "$mainMod SHIFT, up, resizeactive, 0 -10"
          "$mainMod SHIFT, down, resizeactive, 0 10"
          "$mainMod, S, togglespecialworkspace, magic"
        ]
        ++ (
          # workspaces
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

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################
      # WIP
    };
  };
}
