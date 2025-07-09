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
        server_name vault.*;
        include /config/nginx/ssl.conf;
        client_max_body_size 0;
        location / {
            include /config/nginx/proxy.conf;
            include /config/nginx/resolver.conf;
            set $upstream_app vaultwarden;
            set $upstream_port 80;
            set $upstream_proto http; #change to https if app requires
            proxy_pass $upstream_proto://$upstream_app:$upstream_port;
        }
    }
  '';
in {
  imports = [./docker-compose.nix];

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."vaultwarden" = {
    container = "vaultwarden";
    subdomain = "vault";
    port = "80";
    protocol = "http";
  };

  # Create directories for appdata
  # d to create the directory, Z to recursively correct ownership (only needed when restoring from backup)
  systemd.tmpfiles.rules = [
    "d ${serviceOpts.dockerDir}/vaultwarden/config 0700 ${serviceOpts.dockerUser} users"
    "Z ${serviceOpts.dockerDir}/vaultwarden/config - ${serviceOpts.dockerUser} users"
  ];

  # Swag reverse proxy config
  systemd.tmpfiles.settings."01-proxy-confs" = {
    "${serviceOpts.dockerDir}/swag/proxy-confs/vaultwarden.subdomain.conf" = {
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
