{serviceOpts, config, ...}: let
  proxy-conf = ''
    # This is just a template based on common settings. If there's a template from swag available, replace this text with that.
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name photos.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app immich_server;
            set $upstream_port 2283;
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
    "d ${serviceOpts.dockerDir}/immich_server/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/immich_server/config - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/immich_server/db 0766 999 users"
    "Z ${serviceOpts.dockerDir}/immich_server/db - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/immich_server/ml 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/immich_server/ml - ${serviceOpts.dockerUser} users"
  ];

  # pull secret env file
  sops.secrets = {
    "selfhosting/immich/env-app".owner = config.users.users.${serviceOpts.dockerUser}.name;
    "selfhosting/immich/env-db".owner = config.users.users.${serviceOpts.dockerUser}.name;
  };

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/immich_server.subdomain.conf" = {
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
