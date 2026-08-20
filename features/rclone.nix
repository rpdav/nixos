{inputs, ...}: {
  flake.nixosModules.rclone = {config, ...}: {
    sops.secrets = {
      # Pull B2 credentials from secrets
      "rclone/b2/account" = {
      };
      "rclone/b2/key" = {
      };
      "rclone/crypt/password" = {};
    };
    # Create rclone config from secrets
    sops.templates."rclone.conf".content = ''
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
}
