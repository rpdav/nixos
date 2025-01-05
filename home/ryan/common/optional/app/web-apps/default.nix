{userOpts, secrets, ...}: {
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

    unraid = {
      name = "Unraid";
      comment = "";
      settings.StartupWMClass = "chrome-10-10-1-17.5d5ec17f8d70f5b25a8a8817d686fad852ed30ff.myunraid.net__-Default";
      exec = "chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app=\"https://10-10-1-17.5d5ec17f8d70f5b25a8a8817d686fad852ed30ff.myunraid.net\" %U";
      icon = "/home/${userOpts.username}/.local/share/icons/unraid.png";
      terminal = false;
      categories = ["Application"];
      type = "Application";
    };
  };

  # Icons
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
  home.file."unraid.png" = {
    source = ./icons/unraid.png;
    target = ".local/share/icons/unraid.png";
  };
}
