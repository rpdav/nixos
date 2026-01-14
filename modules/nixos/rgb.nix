{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.services.hardware.openrgb.autostart;
in {
  options.services.hardware.openrgb.autostart = {
    enable = mkEnableOption "Auto-start openrgb with defined mode, brightness, and color options";
    mode = mkOption {
      type = types.enum [
        "direct"
        "static"
        "breathing"
        "flashing"
        "double flashing"
        "lightning"
        "meteor"
        "color ring"
        "planetary"
        "double meteor"
        "energy"
        "blink"
        "clock"
        "color pulse"
        "color shift"
        "color wave"
        "marquee"
        "rainbow wave"
        "visor"
        "rainbow flashing"
        "color ring double flashing"
        "stack"
        "fire"
      ];
      default = "static";
      description = "RGB mode";
    };
    color = mkOption {
      type = types.nullOr types.str;
      default = "random";
      description = "Color, by common name (red) or 6-digit hex (ff0000)";
    };
    brightness = mkOption {
      type = types.int;
      default = 100;
      description = "Brightness (0-100)";
    };
  };

  config = let
    color-flag =
      if builtins.isNull cfg.color
      then ""
      else "--color ${cfg.color}";
    rgb-autostart = pkgs.writeScriptBin "rgb-autostart" ''
      #!/bin/sh
      NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --list-devices | grep -E '^[0-9]+: ' | wc -l)

      for i in $(seq 0 $(($NUM_DEVICES - 1))); do
        ${pkgs.openrgb}/bin/openrgb --device $i --mode '${cfg.mode}' ${color-flag} --brightness ${builtins.toString cfg.brightness}
      done
    '';
  in
    lib.mkIf cfg.enable {
      systemd.services.rgb-autostart = {
        description = "rgb-autostart";
        serviceConfig = {
          ExecStart = "${rgb-autostart}/bin/rgb-autostart";
          Type = "oneshot";
        };
        wantedBy = ["multi-user.target"];
        after = ["openrgb.service"];
      };
    };
}
