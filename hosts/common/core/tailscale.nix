{
  config,
  lib,
  ...
}: {
  # Create impermanent directory
  environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
    directories = [
      "/var/lib/tailscale"
    ];
  };
  sops.secrets."tailscale/authkey" = {};

  # Enable tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/authkey".path;
    extraUpFlags = [
      "--reset" # Force Tailscale to only use the declared flags during reauth
    ];
  };
}
