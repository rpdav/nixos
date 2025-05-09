{
  serviceOpts,
  config,
  ...
}: let
  proxy-conf = ''
    # home-assistant
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name home.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app home-assistant-app;
            set $upstream_port 8123;
            set $upstream_proto http; #change to https if app requires
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
    }
    # zwave
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name zwave.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app home-assistant-zwave;
            set $upstream_port 8091;
            set $upstream_proto http; #change to https if app requires
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
    }
  '';
in {
  imports = [./docker-compose.nix];

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/db 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/db - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/Home-Assistant-Core/zwave 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/Home-Assistant-Core/zwave - ${serviceOpts.dockerUser} users"
  ];

  # Secret env file
  sops.secrets."selfhosting/home-assistant/env".owner = config.users.users.${serviceOpts.dockerUser}.name;

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/home-assistant.subdomain.conf" = {
      "f+" = {
        group = "users";
        user = "${serviceOpts.dockerUser}";
        mode = "0700";
        # Convert multiline string to single for tmpfiles
        argument = proxy-conf;
      };
    };
  };
}
