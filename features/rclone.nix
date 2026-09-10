{
  flake.nixosModules.rclone = {
    config,
    pkgs,
    ...
  }: let
    rclone-restore = pkgs.writeShellScriptBin "rclone-restore" ''
      rm -rf /tmp/rclone
      mkdir -p /tmp/rclone/{B2,crypt}
      ${pkgs.rclone}/bin/rclone mount B2:rpdav-rclone /tmp/rclone/B2 --daemon
      ${pkgs.rclone}/bin/rclone mount B2-crypt: /tmp/rclone/crypt --daemon
    '';
  in {
    sops.secrets = {
      # Pull B2 credentials from secrets
      "rclone/b2/account" = {};
      "rclone/b2/key" = {};
      "rclone/crypt/password" = {};
    };
    # Create rclone config from secrets
    sops.templates."rclone.conf" = {
      owner = config.systemOpts.primaryUser;
      content = ''
        [B2]
        type = b2
        account = ${config.sops.placeholder."rclone/b2/account"}
        key = ${config.sops.placeholder."rclone/b2/key"}
        hard_delete = true

        [B2-crypt]
        type = crypt
        remote = B2:rpdav-rclone/crypt
        password = ${config.sops.placeholder."rclone/crypt/password"}
      '';
    };

    # Add rclone.conf location to env
    environment.variables.RCLONE_CONFIG = config.sops.templates."rclone.conf".path;
    security.sudo.extraConfig = ''
      Defaults env_keep += "RCLONE_CONFIG"
    '';

    # Add mounting helper script
    environment.systemPackages = [rclone-restore];
  };
}
