{inputs, ...}: {
  flake.serviceModules.attic = {
    config,
    lib,
    ...
  }: {
    # Decrypt secrets
    sops.secrets = {
      "attic/rs256-secret" = {};
      "attic/b2-key-id" = {};
      "attic/b2-application-key" = {};
    };

    # Construct env file from secrets
    sops.templates."atticd-env".content = ''
      ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."attic/rs256-secret"}
      AWS_ACCESS_KEY_ID=${config.sops.placeholder."attic/b2-key-id"}
      AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."attic/b2-application-key"}
    '';

    # Create service user
    users.users.atticd = {
      isSystemUser = true;
      group = "atticd";
    };
    users.groups.atticd = {};

    services.atticd = {
      enable = true;
      user = "atticd";
      environmentFile = config.sops.templates."atticd-env".path;
      settings = {
        listen = "0.0.0.0:8080"; # firewall below restricts this to the docker bridge only
        api-endpoint = "https://nix.${inputs.nix-secrets.selfhosting.domain}/";

        database.url = "sqlite:///var/lib/atticd/server.db";

        storage = {
          type = "s3";
          region = "us-west-001";
          bucket = "rpdav-attic";
          endpoint = "https://s3.us-west-001.backblazeb2.com";
        };

        # Same chunking caveat Attic's own docs give: changing these later hurts
        # dedup for existing chunks, so treat this block as fixed once you deploy it.
        chunking = {
          nar-size-threshold = 64 * 1024;
          min-size = 16 * 1024;
          avg-size = 64 * 1024;
          max-size = 256 * 1024;
        };

        garbage-collection = {
          interval = "12h";
          default-retention-period = "3 months";
        };
      };
    };

    # Restrict access to the proxynet bridge network
    networking.firewall.interfaces."br-742ba84d6610".allowedTCPPorts = [8080];

    environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
      directories = [
        {
          directory = "/var/lib/atticd";
          user = "atticd";
          group = "atticd";
          mode = "0750";
        }
      ];
    };

    virtualisation.oci-containers.proxyConfs."attic" = {
      container = "172.26.0.1"; # proxynet gateway from swag module
      subdomain = "nix";
      port = 8080;
    };
  };
}
