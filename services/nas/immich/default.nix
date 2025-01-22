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

  # Create directories for appdata and photos
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/immich/db 0700 999 users"
    "Z ${serviceOpts.dockerDir}/immich/db - 999 users"
    "d ${serviceOpts.dockerDir}/immich/model-cache 0755 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/immich/model-cache - ${serviceOpts.dockerUser} users"
    "d /mnt/docker/photos/immich 0755 ${serviceOpts.dockerUser} users"
    "Z /mnt/docker/photos/immich - ${serviceOpts.dockerUser} users"
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
