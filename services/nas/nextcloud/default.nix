{serviceOpts, ...}: let
  proxy-conf = ''
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name cloud.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app nextcloud;
            set $upstream_port 443;
            set $upstream_proto https; #change to https if app requires
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
        location ^~ /.well-known {
            # The rules in this block are an adaptation of the rules
            # in `.htaccess` that concern `/.well-known`.

            location = /.well-known/carddav { return 301 /remote.php/dav/; }
            location = /.well-known/caldav  { return 301 /remote.php/dav/; }

            location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
            location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

            # Let Nextcloud's API for `/.well-known` URIs handle all other
            # requests by passing them to the front-end controller.
            return 301 /index.php$request_uri;
        }
    }
  '';
in {
  imports = [./docker-compose.nix];

  # Create directories
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/nextcloud/config 0700 ${serviceOpts.dockerUser} users" # app config
    "Z ${serviceOpts.dockerDir}/nextcloud/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/nextcloud/db 0700 ${serviceOpts.dockerUser} users" # db config
    "Z ${serviceOpts.dockerDir}/nextcloud/db - ${serviceOpts.dockerUser} users"
    "d /mnt/docker/nextcloud 0700 ${serviceOpts.dockerUser} users" # app data
    "Z /mnt/docker/nextcloud - ${serviceOpts.dockerUser} users"
  ];

  # Secret env file
  sops.secrets."selfhosting/nextcloud/env" = {};

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/nextcloud.subdomain.conf" = {
      "f+" = {
        group = "users";
        user = "${serviceOpts.dockerUser}";
        mode = "0700";
        # Convert multiline string to single for tmpfiles
        argument = builtins.replaceStrings ["\n"] ["\\n"] proxy-conf;
      };
    };
  };
}
