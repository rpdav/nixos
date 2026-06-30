{self, ...}: {
  ## Enables stylix theming for noctalia v5.
  ## Will eventually replace this with upstream

  flake.modules.homeManager.stylixNoctaliav5 = {
    config,
    lib,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    config = lib.mkIf config.programs.noctalia.enable {
      ## colors and polarity
      xdg.configFile.noctaliaStylix = {
        enable = true;
        target = "noctalia/palettes/stylix.json";
        text = builtins.toJSON {
          "${config.stylix.polarity}" = {
            mPrimary = colors.base0D;
            mOnPrimary = colors.base00;
            mSecondary = colors.base0E;
            mOnSecondary = colors.base00;
            mTertiary = colors.base0C;
            mOnTertiary = colors.base00;
            mError = colors.base08;
            mOnError = colors.base00;
            mSurface = colors.base00;
            mOnSurface = colors.base05;
            mHover = colors.base0C;
            mOnHover = colors.base00;
            mSurfaceVariant = colors.base01;
            mOnSurfaceVariant = colors.base04;
            mOutline = colors.base03;
            mShadow = colors.base00;
            # This is basically replicating stlyix handling for kitty.
            # Colors for shell won't work unless terminal is defined too.
            terminal = {
              background = colors.base00;
              foreground = colors.base05;
              cursor = colors.base05;
              cursorText = colors.base00;
              selectionBg = colors.base03;
              selectionFg = colors.base05;
              normal = {
                black = colors.base00;
                red = colors.base0C;
                green = colors.base0B;
                yellow = colors.base0A;
                blue = colors.base0D;
                magenta = colors.base0E;
                cyan = colors.base0C;
                white = colors.base05;
              };
              bright = {
                black = colors.base03;
                red = colors.base0C;
                green = colors.base0B;
                yellow = colors.base0A;
                blue = colors.base0D;
                magenta = colors.base0E;
                cyan = colors.base0C;
                white = colors.base07;
              };
            };
          };
        };
      };

      programs.noctalia.settings.theme = {
        mode = config.stylix.polarity;
        source = "custom";
        custom_palette = "stylix";
      };

      ## opacity
      # skipped

      ## fonts
      # skipped - stylix and noctalia font names don't seem to perfectly correlate

      ## image
      programs.noctalia.settings.wallpaper = {
        default = {path = config.stylix.image;};
        directory = "${self}/themes";
      };
    };
  };
}
