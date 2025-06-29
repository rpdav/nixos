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

  # Shortcut to edit hyprland config
  programs.bash = {
    shellAliases = {
      hypredit = "vim ~/.config/hypr/hyprland.conf";
    };
  };

  # core utilities
  home.packages = with pkgs; [
    #nautilus
    brightnessctl
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

  # Temporary - will iterate on hyprland.conf then convert it to nix when done
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/hypr"
    ];
  };
  home.file.".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/nixos/home/ryan/common/optional/wm/hyprland/hyprland.conf";

  #  wayland.windowManager.hyprland = {
  #    enable = true;
  #    plugins = [];
  #    settings = {
  #      ################
  #      ### MONITORS ###
  #      ################
  #
  #      ###################
  #      ### MY PROGRAMS ###
  #      ###################
  #
  #      "$terminal" = "${pkgs.kitty}/bin/kitty";
  #      "$fileManager" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  #      "$menu" = "${pkgs.rofi}/bin/rofi";
  #      "$browser" = "${pkgs.firefox}/bin/firefox";
  #
  #      #################
  #      ### AUTOSTART ###
  #      #################
  #
  #      exec-once = [
  #        "${pkgs.waybar}/bin/waybar"
  #      ];
  #
  #      ###################
  #      ### KEYBINDINGS ###
  #      ###################
  #
  #      "$mainMod" = "SUPER";
  #      bind =
  #        [
  #          "$mainMod, Q, exec, $terminal"
  #          "$mainMod, C, killactive,"
  #          "$mainMod, M, exit,"
  #          "$mainMod, E, exec, $fileManager"
  #          "$mainMod, B, exec, $browser"
  #          "$mainMod, V, togglefloating,"
  #          "$mainMod, R, exec, $menu -show drun"
  #          "$mainMod, P, pseudo," # dwindle
  #          "$mainMod, J, togglesplit," # dwindle
  #
  #          "$mainMod, left, movefocus, l"
  #          "$mainMod, right, movefocus, r"
  #          "$mainMod, up, movefocus, u"
  #          "$mainMod, down, movefocus, d"
  #        ]
  #        ++ (
  #          # workspaces
  #          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
  #          builtins.concatLists (builtins.genList (
  #              i: let
  #                ws = i + 1;
  #              in [
  #                "$mainMod, code:1${toString i}, workspace, ${toString ws}"
  #                "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
  #              ]
  #            )
  #            9)
  #        );
  #      bindel = [
  #        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  #        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  #        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
  #        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
  #        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
  #      ];
  #
  #      ############
  #      ### MISC ###
  #      ############
  #
  #      input.touchpad.natural_scroll = true;
  #    };
  #  };
}
