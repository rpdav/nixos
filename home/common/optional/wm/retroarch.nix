{...}: {
  # This module contains any retroarch config not covered by `system/common/optional/wm/retroarch.nix`
  programs.retroarch = {
    enable = true;
    settings = {
      rgui_browser_directory = "~/Games";
    };
  };
}
