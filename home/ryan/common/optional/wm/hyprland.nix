{pkgs, ...}: {
  home.packages = with pkgs; [
    kdePackages.dolphin
  ];

  # launcher
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    modes = [
      "drun"
      "ssh"
    ];
  };

  #waybar
  programs.waybar = {
    enable = true;
  };

  #notifications

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    settings = {
      ################
      ### MONITORS ###
      ################

      ###################
      ### MY PROGRAMS ###
      ###################

      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$fileManager" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      "$menu" = "${pkgs.rofi}/bin/rofi";

      #################
      ### AUTOSTART ###
      #################

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
      ];

      ###################
      ### KEYBINDINGS ###
      ###################

      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu -show drun"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle
      ];
    };
  };
}
