{...}: let
  icons = {
    lock = ./icons/catppuccin-mocha/lock.svg;
    reboot = ./icons/catppuccin-mocha/reboot.svg;
    logout = ./icons/catppuccin-mocha/logout.svg;
    shutdown = ./icons/catppuccin-mocha/shutdown.svg;
    suspend = ./icons/catppuccin-mocha/suspend.svg;
    hibernate = ./icons/catppuccin-mocha/hibernate.svg;
  };
in {
  # colors taken from https://github.com/catppuccin/wlogout
  # TODO: integrate this with stylix/system theming sometime
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
      	background-color: rgba(30, 30, 46, 0.90);
      }

      button {
      	border-radius: 0;
      	border-color: #74c7ec;
      	text-decoration-color: #cdd6f4;
      	color: #cdd6f4;
      	background-color: #181825;
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
