{
  config,
  pkgs,
  secrets,
  ...
}: {
  programs.thunderbird = {
    enable = true;
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
    profiles.ryan = {
      isDefault = true;
    };
  };

  accounts.email.accounts = {
    personal = {
      address = "${secrets.personal-mail.address}";
      userName = "${secrets.personal-mail.address}";
      realName = "${secrets.personal-mail.realName}";
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

  #TODO this isn't working
  accounts.contact = {
    basePath = "contacts";
    accounts.nextcloud = {
      remote = {
        type = "carddav";
        url = "${secrets.calendar.url}";
        userName = "${secrets.calendar.user}";
        passwordCommand = "echo ${secrets.calendar.password}";
      };
    };
  };
}
