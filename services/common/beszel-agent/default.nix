{secrets, ...}: {
  services.beszel.agent = {
    enable = true;
    openFirewall = true;
    environment = {
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINS1C1EsOwt0sForUyx88AL5tw+zL78+JwjadiskjtDN"; # pubkey of beszel-hub;
      HUB_URL = "status.${secrets.selfhosting.domain}";
    };
  };
}
