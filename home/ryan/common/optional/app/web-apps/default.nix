{
  userOpts,
  secrets,
  ...
}: {
  # The StartumpWMClass must match this format in order to group windows properly. I'm not sure why this format in particular
  # Pulled from repo https://github.com/bashfulrobot/nixos/tree/65bb54076ef00f08a1289a96425d68bf5e1f4036/modules/apps/web-apps

  # If this gets unwieldy, consider making a webapp module like https://github.com/TLATER/dotfiles/blob/master/home-modules/firefox-webapp.nix

  # Desktop file definitions
  xdg.desktopEntries = {
    actual = {
      name = "Actual Budget";
      comment = "Zero-base budgeting app";
      settings.StartupWMClass = "chrome-budget.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https://budget.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/actual.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    nextcloud = {
      name = "Nextcloud";
      comment = "Self-hosted cloud";
      settings.StartupWMClass = "chrome-cloud.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https://cloud.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/nextcloud.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    silverbullet = {
      name = "SilverBullet";
      comment = "Markdown notes app";
      settings.StartupWMClass = "chrome-notes.${secrets.selfhosting.domain}__-Default";
      settings.Keywords = "notes";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https://notes.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/silverbullet.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    home-assistant = {
      name = "Home Assistant";
      comment = "Smart home automation";
      settings.StartupWMClass = "chrome-home.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https://home.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/home-assistant.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    planka = {
      name = "Planka";
      comment = "Kanban Project Management";
      settings.StartupWMClass = "chrome-projects.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https:projects.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/planka.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    ticktick = {
      name = "TickTick";
      comment = "To-Do List";
      settings.StartupWMClass = "chrome-ticktick.com__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https:ticktick.com\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/ticktick.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };

    # icon isn't working for duplicati - think the WMClass is wrong
    duplicati = {
      name = "Duplicati";
      comment = "Backups";
      settings.StartupWMClass = "chrome-localhost-8200__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"http://localhost:8200\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/duplicati.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };
  };

  # Icons
  # check https://selfh.st/icons/

  home.file."actual.png" = {
    source = ./icons/actual.png;
    target = ".local/share/icons/actual.png";
  };

  home.file."nextcloud.png" = {
    source = ./icons/nextcloud.png;
    target = ".local/share/icons/nextcloud.png";
  };

  home.file."silverbullet.png" = {
    source = ./icons/silverbullet.png;
    target = ".local/share/icons/silverbullet.png";
  };

  home.file."home-assistant.png" = {
    source = ./icons/home-assistant.png;
    target = ".local/share/icons/home-assistant.png";
  };
  home.file."planka.png" = {
    source = ./icons/planka.png;
    target = ".local/share/icons/planka.png";
  };
  home.file."ticktick.png" = {
    source = ./icons/ticktick.png;
    target = ".local/share/icons/ticktick.png";
  };
  home.file."duplicati.png" = {
    source = ./icons/duplicati.png;
    target = ".local/share/icons/duplicati.png";
  };
}
