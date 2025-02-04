{
  serviceOpts,
  config,
  ...
}: let
  proxy-conf = ''
    # This is just a template based on common settings. If there's a template from swag available, replace this text with that.
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name search.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app searxng-app;
            set $upstream_port 8080;
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
    "d ${serviceOpts.dockerDir}/searxng/config 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/searxng/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/searxng/redis 0755 999 users"
    "Z ${serviceOpts.dockerDir}/searxng/redis - 999 users"
  ];

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/searxng.subdomain.conf" = {
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
