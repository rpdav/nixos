{
  serviceOpts,
  pkgs,
  ...
}: let
  proxy-conf = ''
    # This is just a template based on common settings. If there's a template from swag available, replace this text with that.
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name status.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app 10.10.1.17;
            set $upstream_port 8090;
            set $upstream_proto http; #change to https if app requires
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
    }
  '';
in {
  networking.firewall = {
    allowedTCPPorts = [8090];
  };

  systemd.services.beszel-hub = {
    description = "Beszel Hub";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 3;
      User = "${serviceOpts.dockerUser}";
      WorkingDirectory = "${serviceOpts.dockerDir}/beszel-hub";
      ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http \"0.0.0.0:8090\"";
    };
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/beszel-hub 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/beszel-hub - ${serviceOpts.dockerUser} users"
  ];

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/beszel.subdomain.conf" = {
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
