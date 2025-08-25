{
  inputs,
  config,
  pkgs,
  secrets,
  configLib,
  ...
}: {
  imports = [(configLib.relativeToRoot "./modules/home-manager/web-app.nix")];
  programs.firefox.webapps = let
    domain = secrets.selfhosting.domain;
    commonConfig = {
      enable = true;
      extensions.packages = with inputs.firefox-addons.packages."${pkgs.system}"; [
        bitwarden
        ublock-origin
      ];
      theme = config.stylix.polarity;
    };
  in {
    # id must be a unique integer. Note that the default firefox profile is 0, so start with 1.
    # extensions will need to be manually enabled in about:addons. Any extensions that need auth (like password managers) will need to be individually signed on, but should stay signed in after that.

    actual =
      commonConfig
      // {
        id = 1;
        url = "https://budget.${domain}";
        name = "Actual Budget";
        genericName = "Budgeting Application";
        icon = ./icons/actual.png;
        categories = [
          "Office"
        ];
      };
    nextcloud =
      commonConfig
      // {
        id = 2;
        url = "https://cloud.${domain}";
        name = "Nextcloud";
        genericName = "Cloud Synchronization";
        icon = ./icons/nextcloud.png;
        categories = [
          "Network"
          "Office"
        ];
      };
    home-assistant =
      commonConfig
      // {
        id = 3;
        url = "https://home.${domain}";
        name = "Home Assistant";
        genericName = "Home Automation";
        icon = ./icons/home-assistant.png;
        categories = [
          "Network"
        ];
      };
    planka =
      commonConfig
      // {
        enable = true;
        id = 4;
        url = "https://projects.${domain}";
        name = "Planka";
        genericName = "Kanban Project Management";
        icon = ./icons/planka.png;
        categories = [
          "Utility"
        ];
      };
    ticktick =
      commonConfig
      // {
        id = 5;
        url = "https://ticktick.com";
        name = "TickTick";
        genericName = "Task Manager";
        icon = ./icons/ticktick.png;
        categories = [
          "Utility"
        ];
      };
    sketchup =
      commonConfig
      // {
        id = 6;
        url = "https:app.sketchup.com";
        name = "Sketchup";
        genericName = "3D Design App";
        icon = ./icons/sketchup.png;
        categories = [
          "Graphics"
        ];
      };
    flatnotes =
      commonConfig
      // {
        id = 7;
        url = "https://notes.${domain}";
        name = "Flatnotes";
        genericName = "Note Taking";
        icon = ./icons/flatnotes.png;
        categories = [
          "Office"
        ];
      };
  };
}
