# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  uptix,
  secrets,
  config,
  ...
}: {
  # Containers
  virtualisation.oci-containers.containers."dms" = {
    image = uptix.dockerImage "ghcr.io/docker-mailserver/docker-mailserver:latest";
    environment = {
      "ACCOUNT_PROVISIONER" = "";
      "AMAVIS_LOGLEVEL" = "0";
      "CLAMAV_MESSAGE_SIZE_LIMIT" = "";
      "DEFAULT_RELAY_HOST" = "";
      "DMS_DEBUG" = "0";
      "DOVECOT_AUTH_BIND" = "";
      "DOVECOT_INET_PROTOCOLS" = "all";
      "DOVECOT_MAILBOX_FORMAT" = "maildir";
      "DOVECOT_PASS_FILTER" = "";
      "DOVECOT_TLS" = "";
      "DOVECOT_USER_FILTER" = "";
      "ENABLE_AMAVIS" = "1";
      "ENABLE_CLAMAV" = "0";
      "ENABLE_DNSBL" = "0";
      "ENABLE_FAIL2BAN" = "1";
      "ENABLE_FETCHMAIL" = "0";
      "ENABLE_LDAP" = "";
      "ENABLE_MANAGESIEVE" = "";
      "ENABLE_OPENDKIM" = "1";
      "ENABLE_OPENDMARC" = "1";
      "ENABLE_POLICYD_SPF" = "1";
      "ENABLE_POP3" = "";
      "ENABLE_POSTGREY" = "0";
      "ENABLE_QUOTAS" = "1";
      "ENABLE_RSPAMD" = "0";
      "ENABLE_RSPAMD_REDIS" = "";
      "ENABLE_SASLAUTHD" = "0";
      "ENABLE_SPAMASSASSIN" = "0";
      "ENABLE_SPAMASSASSIN_KAM" = "0";
      "ENABLE_SRS" = "0";
      "ENABLE_UPDATE_CHECK" = "1";
      "FAIL2BAN_BLOCKTYPE" = "drop";
      "FETCHMAIL_POLL" = "300";
      "LDAP_BIND_DN" = "";
      "LDAP_BIND_PW" = "";
      "LDAP_QUERY_FILTER_ALIAS" = "";
      "LDAP_QUERY_FILTER_DOMAIN" = "";
      "LDAP_QUERY_FILTER_GROUP" = "";
      "LDAP_QUERY_FILTER_USER" = "";
      "LDAP_SEARCH_BASE" = "";
      "LDAP_SERVER_HOST" = "";
      "LDAP_START_TLS" = "";
      "LOGROTATE_INTERVAL" = "weekly";
      "LOGWATCH_INTERVAL" = "";
      "LOGWATCH_RECIPIENT" = "";
      "LOGWATCH_SENDER" = "";
      "LOG_LEVEL" = "info";
      "MOVE_SPAM_TO_JUNK" = "1";
      "NETWORK_INTERFACE" = "";
      "ONE_DIR" = "1";
      "OVERRIDE_HOSTNAME" = "";
      "PERMIT_DOCKER" = "none";
      "PFLOGSUMM_RECIPIENT" = "";
      "PFLOGSUMM_SENDER" = "";
      "PFLOGSUMM_TRIGGER" = "";
      "POSTFIX_DAGENT" = "";
      "POSTFIX_INET_PROTOCOLS" = "all";
      "POSTFIX_MAILBOX_SIZE_LIMIT" = "";
      "POSTFIX_MESSAGE_SIZE_LIMIT" = "";
      "POSTFIX_REJECT_UNKNOWN_CLIENT_HOSTNAME" = "0";
      "POSTGREY_AUTO_WHITELIST_CLIENTS" = "5";
      "POSTGREY_DELAY" = "300";
      "POSTGREY_MAX_AGE" = "35";
      "POSTGREY_TEXT" = "Delayed by Postgrey";
      "POSTMASTER_ADDRESS" = "";
      "POSTSCREEN_ACTION" = "enforce";
      "RELAY_HOST" = "";
      "RELAY_PASSWORD" = "";
      "RELAY_PORT" = "25";
      "RELAY_USER" = "";
      "REPORT_RECIPIENT" = "";
      "REPORT_SENDER" = "";
      "RSPAMD_GREYLISTING" = "0";
      "RSPAMD_HFILTER" = "1";
      "RSPAMD_HFILTER_HOSTNAME_UNKNOWN_SCORE" = "6";
      "RSPAMD_LEARN" = "0";
      "SASLAUTHD_LDAP_AUTH_METHOD" = "";
      "SASLAUTHD_LDAP_BIND_DN" = "";
      "SASLAUTHD_LDAP_FILTER" = "";
      "SASLAUTHD_LDAP_MECH" = "";
      "SASLAUTHD_LDAP_PASSWORD" = "";
      "SASLAUTHD_LDAP_PASSWORD_ATTR" = "";
      "SASLAUTHD_LDAP_SEARCH_BASE" = "";
      "SASLAUTHD_LDAP_SERVER" = "";
      "SASLAUTHD_LDAP_START_TLS" = "";
      "SASLAUTHD_LDAP_TLS_CACERT_DIR" = "";
      "SASLAUTHD_LDAP_TLS_CACERT_FILE" = "";
      "SASLAUTHD_LDAP_TLS_CHECK_PEER" = "";
      "SASLAUTHD_MECHANISMS" = "";
      "SASLAUTHD_MECH_OPTIONS" = "";
      "SA_KILL" = "10.0";
      "SA_SPAM_SUBJECT" = "***SPAM*****";
      "SA_TAG" = "2.0";
      "SA_TAG2" = "6.31";
      "SMTP_ONLY" = "";
      "SPAMASSASSIN_SPAM_TO_INBOX" = "1";
      "SPOOF_PROTECTION" = "";
      "SRS_EXCLUDE_DOMAINS" = "";
      "SRS_SECRET" = "";
      "SRS_SENDER_CLASSES" = "envelope_sender";
      "SSL_ALT_CERT_PATH" = "";
      "SSL_ALT_KEY_PATH" = "";
      "SSL_CERT_PATH" = "";
      "SSL_KEY_PATH" = "";
      "SSL_TYPE" = "letsencrypt";
      "SUPERVISOR_LOGLEVEL" = "";
      "TLS_LEVEL" = "";
      "TZ" = config.time.timeZone;
      "UPDATE_CHECK_INTERVAL" = "1d";
      "VIRUSMAILS_DELETE_DELAY" = "";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${config.serviceOpts.dockerDir}/dms/config/:/tmp/docker-mailserver:rw"
      "${config.serviceOpts.dockerDir}/dms/mail-data/:/var/mail:rw"
      "${config.serviceOpts.dockerDir}/dms/mail-logs/:/var/log/mail:rw"
      "${config.serviceOpts.dockerDir}/dms/mail-state/:/var/mail-state:rw"
      "${config.serviceOpts.dockerDir}/swag/config/etc/letsencrypt/:/etc/letsencrypt:ro"
    ];
    ports = [
      "25:25/tcp"
      "143:143/tcp"
      "465:465/tcp"
      "587:587/tcp"
      "993:993/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--health-cmd=ss --listening --tcp | grep -P 'LISTEN.+:smtp' || exit 1"
      "--health-retries=0"
      "--health-timeout=3s"
      "--hostname=${secrets.ryan.email.admin-mail.host}"
      "--network-alias=dms"
      "--network=dms_default"
    ];
  };
  systemd.services."docker-dms" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-dms_default.service"
    ];
    requires = [
      "docker-network-dms_default.service"
    ];
    partOf = [
      "docker-compose-dms-root.target"
    ];
    wantedBy = [
      "docker-compose-dms-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-dms_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f dms_default";
    };
    script = ''
      docker network inspect dms_default || docker network create dms_default
    '';
    partOf = ["docker-compose-dms-root.target"];
    wantedBy = ["docker-compose-dms-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-dms-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
