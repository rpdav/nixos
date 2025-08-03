{
  config,
  osConfig,
  secrets,
  lib,
  ...
}: {
  sops.secrets = {
    "email/admin-mail/password" = {};
    "email/personal-mail/password" = {};
    "dav/password" = {};
  };

  # Create persistent directories
  home.persistence."${osConfig.systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/protonmail"
      ".config/evolution" #calendar config
      ".config/goa-1.0" #dav accounts
    ];
  };

  # Email
  accounts.email.accounts = {
    personal = {
      address = secrets.ryan.email.personal-mail.address;
      userName = secrets.ryan.email.personal-mail.address;
      realName = secrets.ryan.email.personal-mail.realName;
      # protonmail-bridge password is likely to reset on reinstall - pull it fresh from cli tool
      # thunderbird password declaration isn't working - this is must be entered imperatively.
      passwordCommand = "cat ${config.sops.secrets."email/personal-mail/password".path}";
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
      address = "${secrets.ryan.email.admin-mail.address}";
      userName = "${secrets.ryan.email.admin-mail.address}";
      realName = "${secrets.ryan.email.admin-mail.realName}";
      # thunderbird password declaration isn't working - this is must be entered imperatively.
      passwordCommand = "cat ${config.sops.secrets."email/admin-mail/password".path}";
      imap = {
        host = secrets.ryan.email.admin-mail.host;
        tls.enable = true;
        port = 993;
      };
      smtp = {
        host = secrets.ryan.email.admin-mail.host;
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
        url = "${secrets.ryan.dav.url}/addressbooks/users/ryan/contacts";
        userName = "${secrets.dav.user}";
        passwordCommand = "cat ${config.sops.secrets."dav/password".path}";
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
        url = "${secrets.ryan.dav.url}";
        userName = "${secrets.ryan.dav.user}";
        passwordCommand = "cat ${config.sops.secrets."dav/password".path}";
      };
      local = {
        type = "singlefile";
        path = "nextcloud";
      };
    };
  };
}
