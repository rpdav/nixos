{
  secrets,
  configLib,
  ...
}: {
  imports = [(configLib.relativeToRoot "./modules/home-manager/web-app.nix")];
  programs.firefox.webapps = let
    domain = secrets.selfhosting.domain;
  in {
    # id must be a unique integer. Note that the default firefox profile is 0, so start with 1.
    # extensions will need to be manually enabled in about:addons. Any extensions that need auth (like password managers) will need to be individually signed on, but should stay signed in after that.

    actual = {
      enable = true;
      id = 1;
      url = "https://budget.${domain}";
      name = "Actual Budget";
      genericName = "Budgeting Application";
      icon = ./icons/actual.png;
      categories = [
        "Office"
      ];
    };
    nextcloud = {
      enable = true;
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
    home-assistant = {
      enable = true;
      id = 3;
      url = "https://home.${domain}";
      name = "Home Assistant";
      genericName = "Home Automation";
      icon = ./icons/home-assistant.png;
      categories = [
        "Network"
      ];
    };
    planka = {
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
    ticktick = {
      enable = true;
      id = 5;
      url = "https://ticktick.com";
      name = "TickTick";
      genericName = "Task Manager";
      icon = ./icons/ticktick.png;
      categories = [
        "Utility"
      ];
    };
    sketchup = {
      enable = true;
      id = 6;
      url = "https:app.sketchup.com";
      name = "Sketchup";
      genericName = "3D Design App";
      icon = ./icons/sketchup.png;
      categories = [
        "Graphics"
      ];
    };
  };
}
