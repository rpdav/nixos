{inputs, ...}: {
  flake.serviceModules.beszelAgent = {config, ...}: {
    sops.secrets."selfhosting/beszel-agent/token" = {
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      owner = "beszel-agent";
    };
    services.beszel.agent = {
      enable = true;
      openFirewall = true;
      environment = {
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINS1C1EsOwt0sForUyx88AL5tw+zL78+JwjadiskjtDN"; # pubkey of beszel-hub;
        HUB_URL = "https://status.${inputs.nix-secrets.selfhosting.domain}";
        TOKEN_FILE = config.sops.secrets."selfhosting/beszel-agent/token".path;
      };
    };

    # Define beszel-hub service user and group to allow access to token
    users.users.beszel-agent = {
      isSystemUser = true;
      group = "beszel-agent";
    };
    users.groups.beszel-agent = {};
  };
}
