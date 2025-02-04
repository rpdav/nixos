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

    vikunja = {
      name = "Vikunja";
      comment = "Task management";
      settings.StartupWMClass = "chrome-todo.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https:todo.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/vikunja.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };
    jellyfin = {
      name = "Jellyfin";
      comment = "Media streaming";
      settings.StartupWMClass = "chrome-movies.${secrets.selfhosting.domain}__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https:movies.${secrets.selfhosting.domain}\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/jellyfin.png";
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
  home.file."vikunja.png" = {
    source = ./icons/vikunja.png;
    target = ".local/share/icons/vikunja.png";
  };
  home.file."jellyfin.png" = {
    source = ./icons/jellyfin.png;
    target = ".local/share/icons/jellyfin.png";
  };
}
