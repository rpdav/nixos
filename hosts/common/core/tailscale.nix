{
  config,
  inputs,
  lib,
  ...
}: {
  # Create impermanent directory
  environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
    directories = [
      "/var/lib/tailscale"
    ];
  };
  sops.secrets."tailscale/authkey" = {
    sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
    restartUnits = ["tailscaled-autoconnect.service"];
  };

  # Enable tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/authkey".path;
    extraUpFlags = [
      "--reset" # Force Tailscale to only use the declared flags during reauth
    ];
  };
}
