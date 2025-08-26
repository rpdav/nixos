{config, ...}: let
  inherit (config.lib.stylix) colors;
  icons = {
    # The colors of these icons are from catppuccin mocha
    # https://github.com/catppuccin/wlogout
    # TODO: make versions for other themes
    lock = ./icons/lock.svg;
    reboot = ./icons/reboot.svg;
    logout = ./icons/logout.svg;
    shutdown = ./icons/shutdown.svg;
    suspend = ./icons/suspend.svg;
    hibernate = ./icons/hibernate.svg;
  };
in {
  programs.wlogout = {
    enable = true;
    layout = [
      {
        action = "loginctl lock-session";
        keybind = "l";
        label = "lock";
        text = "Lock";
      }
      {
        action = "systemctl reboot";
        keybind = "r";
        label = "reboot";
        text = "Reboot";
      }
      {
        action = "loginctl terminate-user $USER";
        keybind = "e";
        label = "logout";
        text = "Logout";
      }
      {
        action = "systemctl poweroff";
        keybind = "s";
        label = "shutdown";
        text = "Shutdown";
      }
      {
        action = "systemctl suspend";
        keybind = "u";
        label = "suspend";
        text = "Suspend";
      }
      {
        action = "systemctl hibernate";
        keybind = "h";
        label = "hibernate";
        text = "Hibernate";
      }
    ];
    style = ''
      * {
      	background-image: none;
      	box-shadow: none;
      }

      window {
      	background-color: #${colors.base00};
      }

      button {
      	border-radius: 0;
      	border-color: #${colors.base0C};
      	text-decoration-color: #${colors.base05};
      	color: #${colors.base05};
      	background-color: #${colors.base01};
      	border-style: solid;
      	border-width: 1px;
      	background-repeat: no-repeat;
      	background-position: center;
      	background-size: 25%;
      }

      button:focus, button:active, button:hover {
      	/* 20% Overlay 2, 80% mantle */
      	background-color: rgb(48, 50, 66);
      	outline-style: none;
      }
      #lock {
          background-image: url("${icons.lock}");
      }

      #logout {
          background-image: url("${icons.logout}");
      }

      #suspend {
          background-image: url("${icons.suspend}");
      }

      #reboot {
          background-image: url("${icons.reboot}");
      }

      #shutdown {
          background-image: url("${icons.shutdown}");
      }

      #hibernate {
          background-image: url("${icons.hibernate}");
      }
    '';
  };
}
