{
  config,
  inputs,
  pkgs,
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

  # Aliases to enable accept routes when travelling
  # Can't leave it on due to using relays when at home
  # See https://github.com/tailscale/tailscale/issues/1227
  programs.bash.shellAliases = {
    travelmode = "sudo ${pkgs.tailscale}/bin/tailscale up --accept-routes";
    homemode = "sudo ${pkgs.tailscale}/bin/tailscale up --reset";
  };
}
