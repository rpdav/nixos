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

  #notifications

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi";
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
