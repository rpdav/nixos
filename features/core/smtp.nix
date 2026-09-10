{inputs, ...}: {
  flake.nixosModules.core = {config, ...}: let
    inherit (inputs.nix-secrets.selfhosting) domain;
    inherit (config.systemOpts) primaryUser;
  in {
    sops.secrets."email/admin-mail/password" = {
      sopsFile = "${inputs.nix-secrets.outPath}/${primaryUser}.yaml";
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
        passwordeval = "cat ${config.sops.secrets."email/admin-mail/password".path}";
      };
    };
  };
}
