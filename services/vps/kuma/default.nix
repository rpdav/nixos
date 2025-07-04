{serviceOpts, ...}: let
  proxy-conf = ''
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name up.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app uptime-kuma;
            set $upstream_port 3001;
            set $upstream_proto http;
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
    }
  '';
in {
  imports = [./docker-compose.nix];

  # Create directories to mount
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/uptime-kuma/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/uptime-kuma/config - ${serviceOpts.dockerUser} users"
  ];

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/uptime-kuma.subdomain.conf" = {
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
