{
  inputs,
  cosmicLib,
  ...
}: {
  imports = [inputs.cosmic-manager.homeManagerModules.cosmic-manager];

  #wayland.desktopManager.cosmic.compositor.input_touchpad.scroll_config.natural_scroll = true; # this does not work - see github issue

  programs.cosmic-files.enable = false;
}
