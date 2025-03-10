{
  config,
  pkgs,
  systemOpts,
  lib,
  ...
}: {
  # Create impermanent directory
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "/var/lib/tailscale"
    ];
  };
  sops.secrets."tailscale/authkey" = {};

  # Install tailscale package
  environment.systemPackages = [pkgs.tailscale];

  # Enable tailscale
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-routes"
    ];
  };

  # Use opnsense router for dns
  networking.nameservers = ["10.10.1.1"];

  # Auto-connect service
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale server
      ${tailscale}/bin/tailscale up --authkey $(cat ${config.sops.secrets."tailscale/authkey".path}) --accept-routes
    '';
  };
}
