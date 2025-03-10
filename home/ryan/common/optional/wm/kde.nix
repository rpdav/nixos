{
  pkgs,
  inputs,
  systemOpts,
  userOpts,
  lib,
  ...
}: {
  imports = [inputs.plasma-manager.homeManagerModules.plasma-manager];

  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/kdedefaults"
      ".config/kde.org"
    ];
    files = [
      ".config/gwenviewrc"
      ".config/kactivitymanagerd-statsrc"
      ".config/konsolerc"
      ".config/konsolesshconfig"
      ".config/krdpserverrc"
      ".config/kwriterc"
    ];
  };

  home.packages = with pkgs; [
    aha
    clinfo
    wayland-utils
    kdePackages.kalk
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true; # delete existing config on reload

    ## Theming is handled by stylix
    #    workspace = {
    #      wallpaper = "/persist/home/${userOpts.username}/Documents/wallpaper.png";
    #      theme = "breeze-dark";
    #      colorScheme = "BreezeDark";
    #      cursor = {
    #        theme = "Breeze_Light";
    #        size = 24;
    #      };
    #      lookAndFeel = "org.kde.default.desktop"; # this is "Plasma Style" in settings
    #      iconTheme = "breeze-dark"; # breeze, breeze-dark, or oxygen
    #      soundTheme = "ocean";
    #
    #    };

    panels = [
      {
        location = "top";
        hiding = "none";
        height = 40;
        floating = false;
        widgets = [
          {
            name = "org.kde.plasma.kickerdash";
            config = {
              General = {
                icon = "nix-snowflake-white";
              };
            };
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                fill = false;
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:thunderbird.desktop"
                  "applications:onlyoffice-desktopeditors.desktop"
                  "applications:kitty.desktop"
                ];
              };
            };
          }
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            name = "org.kde.plasma.pager";
            config = {
              General.displayedText = "Name";
            };
          }
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            systemTray.items = {
              hidden = [
                "org.kde.plasma.printmanager"
                "kded6" #kde browser integration
                "org.kde.plasma.keyboardlayout"
                "blueman"
              ];
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.brightness"
                "org.kde.plasma.battery"
              ];
            };
          }
          {
            #TODO clock broken in kde 6.2.2
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                use24hFormat = true;
              };
            };
          }
        ];
      }
    ];

    shortcuts = {
      "kitty.desktop" = {
        "_launch" = "Ctrl+Alt+T";
      };
      "org.kde.konsole.desktop" = {
        "_launch" = "none";
      };
      "yakuake" = {
        "toggle-window-state" = "Meta+Space";
      };
    };

    configFile = {
      kwinrc.Desktops = {
        Name_1.value = "browse";
        Name_2.value = "dev";
        Name_3.value = "write";
        Number.value = 3;
        Rows.value = 1;
      };
    };
  };
}
