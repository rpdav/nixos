# Themes

Theming is handled by [Stylix](https://nix-community.github.io/stylix/), a nixos module that applies system-wide colors, fonts, icons, cursors, and wallpapers. My stylix config is defined in `system/common/core/stylix.nix`.

The `themes` directory contains subdirectories for each theme with a wallpaper, polarity file, and scheme file. These are all accessed by stylix based on the theme chosen through `userOpts.theme`. I currently have the following themes:

| Theme Name  | Base16Scheme              |
|-------------|---------------------------|
| astronaut   | tokyo-night-terminal-dark |
| everforest  | everforest                |
| gruvbox     | gruvbox-dark-medium       |
| latte       | catppuccin-latte          |
| mocha       | catppuccin-mocha          |
| moon        | tokyo-night-terminal-dark |
| mountain    | catppuccin-latte          |
| nord        | nord                      |
| rainbow-cat | catppuccin-mocha          |
| tokyo       | tokyo-night-terminal-dark |

[Base16Schemes](https://github.com/tinted-theming/schemes?tab=readme-ov-file) are a set of 16 coordinated colors. You can also build your own base16 scheme with stylix if you prefer. You can get scheme names and colors by running `nix build nixpkgs#base16-schemes` and browsing to `result/share/themes`.

