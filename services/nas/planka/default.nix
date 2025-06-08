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
        server_name projects.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app planka-app;
            set $upstream_port 1337;
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
    "d ${serviceOpts.dockerDir}/planka/favicons 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/favicons - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/user-avatars 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/user-avatars - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/background-images 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/background-images - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/attachments 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/attachments - ${serviceOpts.dockerUser} users"
    "d ${serviceOpts.dockerDir}/planka/db-data 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/planka/db-data - 70 users"
  ];

  # pull secret env file
  sops.secrets."selfhosting/planka/env".owner = config.users.users.${serviceOpts.dockerUser}.name;

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/planka.subdomain.conf" = {
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
