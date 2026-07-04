{...}: {
  # This module declares options for monitor layouts and imports
  # them into either hyprland or niri if either or both are enabled.
  flake.modules.homeManager.monitors = {
    lib,
    config,
    options,
    ...
  }: let
    inherit (lib) mkOption types;
    cfg = config.monitors;
    # Function to convert monitor attrset to hyprland "list of strings" syntax
    hyprMonitors = monitors:
      with builtins; let
        convertMonitor = name: value:
          if !(value.enable)
          then "${name}, disable"
          else let
            # Convert all floats and ints to strings
            width = toString value.mode.width;
            height = toString value.mode.height;
            refresh = toString value.mode.refresh;
            posX = toString value.position.x;
            posY = toString value.position.y;
            scale = toString value.scale or 1.0;
            wallet = "${name}, ${width}x${height}@${refresh}, ${posX}x${posY}, ${scale}";
          in
            wallet;
        monitorList = attrValues (mapAttrs convertMonitor monitors);
      in
        monitorList;
  in {
    options.monitors = mkOption {
      description = "Global monitor configuration shared between Niri and Hyprland.";
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable the monitor.";
          };
          mode = mkOption {
            description = "Resolution and refresh rate.";
            type = types.submodule {
              options = {
                width = mkOption {
                  type = types.int;
                  default = 1920;
                  description = "Width in pixels";
                };
                height = mkOption {
                  type = types.int;
                  default = 1080;
                  description = "Height in pixels";
                };
                refresh = mkOption {
                  type = types.float;
                  default = 60.0;
                  description = "Refresh rate in Hz";
                };
              };
            };
          };
          position = mkOption {
            description = "Coordinates in the global compositor space.";
            type = types.submodule {
              options = {
                x = mkOption {
                  type = types.int;
                  default = 0;
                  description = "X coordinate";
                };
                y = mkOption {
                  type = types.int;
                  default = 0;
                  description = "Y coordinate";
                };
              };
            };
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "HiDPI scaling factor.";
          };
          variable-refresh-rate = mkOption {
            type = types.bool;
            default = false;
            description = "Whether the monitor supports VRR.";
          };
        };
      });
    };
    config = lib.mkMerge [
      # Pass directly to Niri. Niri does not have programs.niri.enable. Also, it's an imported homeModule,
      # so we're checking whether the option exists at all; otherwise it'll throw an evaluation error.
      (lib.optionalAttrs (options.programs ? niri) {
        programs.niri.settings.outputs = cfg;
      })

      # Translate and pass to Hyprland
      (lib.mkIf config.wayland.windowManager.hyprland.enable {
        wayland.windowManager.hyprland.settings.monitor = hyprMonitors cfg;
      })
    ];
  };
}
