{config, ...}: let
  inherit (config.serviceOpts) dockerDir dockerUser;
in {
  imports = [./docker-compose.nix];

  # Create/chmod appdata directories to mount
  virtualisation.oci-containers.mounts = {
    "nextcloud" = {};
    "nextcloud-db" = {
      target = "${dockerDir}/nextcloud/db";
    };
    "nextcloud-data" = {
      target = "/mnt/docker/nextcloud";
    };
  };

  # Create swag proxy config
  virtualisation.oci-containers.proxy-conf."nextcloud" = {
    subdomain = "cloud";
    port = 443;
    protocol = "https";
    extraConfig = ''
      # add .well-known redirects per nextcloud
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
    '';
  };

  # Secret env file
  sops.secrets."selfhosting/nextcloud/env".owner = config.users.users.${dockerUser}.name;
}
