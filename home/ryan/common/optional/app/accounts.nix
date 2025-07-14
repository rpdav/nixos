{
  config,
  osConfig,
  secrets,
  lib,
  ...
}: {
  sops.secrets = {
    "admin-mail/password" = {};
    "personal-mail/password" = {};
    "dav/ryan/password" = {};
  };

  # Create persistent directories
  home.persistence."${osConfig.systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.systemOpts.impermanent {
    directories = [
      ".config/protonmail"
      ".cache/evolution" #calendar data
      ".config/evolution" #calendar config
      ".config/goa-1.0" #dav accounts
    ];
  };

  # Email
  accounts.email.accounts = {
    personal = {
      address = "${secrets.personal-mail.address}";
      userName = "${secrets.personal-mail.address}";
      realName = "${secrets.personal-mail.realName}";
      # protonmail-bridge password is likely to reset on reinstall - pull it fresh from cli tool
      # thunderbird password declaration isn't working - this is must be entered imperatively.
      passwordCommand = "cat ${config.sops.secrets."personal-mail/password".path}";
      primary = true;
      imap = {
        host = "127.0.0.1";
        tls.enable = true;
        tls.useStartTls = true;
        port = 1143;
      };
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls.enable = true;
        tls.useStartTls = true;
      };
      thunderbird = {
        enable = true;
        profiles = ["ryan"];
      };
    };
    admin = {
      address = "${secrets.admin-mail.address}";
      userName = "${secrets.admin-mail.address}";
      realName = "${secrets.admin-mail.realName}";
      # thunderbird password declaration isn't working - this is must be entered imperatively.
      passwordCommand = "cat ${config.sops.secrets."admin-mail/password".path}";
      imap = {
        host = "${secrets.admin-mail.host}";
        tls.enable = true;
        port = 993;
      };
      smtp = {
        host = "${secrets.admin-mail.host}";
        tls.enable = true;
        port = 465;
      };
      thunderbird = {
        enable = true;
        profiles = ["ryan"];
      };
    };
  };

  ### These home manager options currently don't integrate with many apps.
  ### Contacts (carddav) are in thunderbird imperatively and calendar
  ### (caldav) is in gnome accounts/evolution. Both rely on state in /persist.
  ### Keeping this config here in case future apps integrate it better

  # Contacts
  accounts.contact = {
    basePath = "~/contacts";
    accounts.nextcloud = {
      remote = {
        type = "carddav";
        url = "${secrets.dav.url}/addressbooks/users/ryan/contacts";
        userName = "${secrets.dav.user}";
        passwordCommand = "cat ${config.sops.secrets."dav/ryan/password".path}";
      };
      local = {
        path = "nextcloud";
        type = "filesystem";
      };
    };
  };

  # Calendar
  accounts.calendar = {
    basePath = "~/.calendar";
    accounts.nextcloud = {
      remote = {
        type = "caldav";
        url = "${secrets.dav.url}";
        userName = "${secrets.dav.user}";
        passwordCommand = "cat ${config.sops.secrets."dav/ryan/password".path}";
      };
      local = {
        type = "singlefile";
        path = "nextcloud";
      };
    };
  };
}
