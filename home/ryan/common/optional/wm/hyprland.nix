{...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    settings = {
      bindd = [
        "Control_L&Alt_L, T, exec, kitty"
      ];
    };
  };
}
