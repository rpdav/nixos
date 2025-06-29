{lib, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      # Mostly taken from sample config. See https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock
      "$font" = "Monospace";

      general = {
        hide_cursor = false;
      };

      auth = {
        pam = {
          module = "login";
        };
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning...";
          retry_delay = "250"; # in milliseconds
        };
      };

      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };

      background = {
        monitor = "";
        blur_passes = 3;
      };

      input-field = {
        monitor = "";
        size = "20%, 5%";
        outline_thickness = 3;
        inner_color = lib.mkForce "rgba(0, 0, 0, 0.0)"; # no fill, override stylix

        #font_color = "rgb(143, 143, 143)"; #stylix
        fade_on_empty = false;
        rounding = 15;

        font_family = "$font";
        placeholder_text = "Input password...";
        fail_text = "$PAMFAIL";

        dots_spacing = 0.3;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };

      label = [
        # TIME
        {
          monitor = "";
          text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
          font_size = 90;
          font_family = "$font";

          position = "-30, 0";
          halign = "right";
          valign = "top";
        }

        # DATE
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%A, %d %B %Y\""; # update every 60 seconds
          font_size = 25;
          font_family = "$font";

          position = "-30, -150";
          halign = "right";
          valign = "top";
        }

        {
          monitor = "";
          text = "$LAYOUT[en,ru]";
          font_size = 24;
          onclick = "hyprctl switchxkblayout all next";

          position = "250, -20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
