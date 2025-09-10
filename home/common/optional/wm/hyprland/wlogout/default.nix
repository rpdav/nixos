{config, ...}: let
  inherit (config.lib.stylix) colors;
  # The *.nix files in ./icons are svgs expressed as nix strings with a placeholder for stylix colors.
  # This let block imports those files so their paths can be inserted into wlogout's style.css.
  # Icons are taken from https://github.com/catppuccin/wlogout
  icons = {
    hibernate =
      import ./icons/hibernate.nix {inherit colors;}
      |> builtins.toFile "hibernate.svg";
    lock =
      import ./icons/lock.nix {inherit colors;}
      |> builtins.toFile "lock.svg";
    logout =
      import ./icons/logout.nix {inherit colors;}
      |> builtins.toFile "logout.svg";
    reboot =
      import ./icons/reboot.nix {inherit colors;}
      |> builtins.toFile "reboot.svg";
    shutdown =
      import ./icons/shutdown.nix {inherit colors;}
      |> builtins.toFile "shutdown.svg";
    suspend =
      import ./icons/suspend.nix {inherit colors;}
      |> builtins.toFile "suspend.svg";
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
      	border-color: #${colors.cyan};
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
