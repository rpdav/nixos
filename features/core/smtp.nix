{inputs, ...}: {
  flake.nixosModules.core = {config, ...}: let
    inherit (inputs.nix-secrets.selfhosting) domain;
  in {
    sops.secrets."admin/email/password" = {
      sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
      mode = "0444"; # allow users to send mail with this account
    };

    programs.msmtp = {
      enable = true;
      defaults = {
        tls = true;
        tls_starttls = true;
        port = 587;
      };
      accounts.default = {
        auth = true;
        host = "mail.${domain}";
        from = "${config.networking.hostName}@${domain}";
        user = "admin@${domain}";
        passwordeval = "cat ${config.sops.secrets."admin/email/password".path}";
      };
    };
  };
}
