{self, ...}: {
  flake.nixosModules.yubikey = {
    config,
    lib,
    ...
  }: {
    imports = [self.modules.nixos.yubikey];
    # enable keys and set identifiers
    yubikey = {
      enable = true;
      identifiers = {
        yubi5c = 23559438;
        yubinano = 31767330;
      };
    };

    programs.yubikey-touch-detector.enable = lib.mkIf config.systemOpts.gui true;

    # Disable physical lockscreen/displayManager login with u2f
    # Use password or fingerprint
    security.pam.services.login.u2fAuth = lib.mkForce false;
  };

  flake.homeModules.yubikey = {
    config,
    lib,
    ...
  }: let
    homeDir = config.home.homeDirectory;
  in {
    # Pull private ssh keys from sops
    sops.secrets = {
      # override default manual key path if yubikey is enabled. If normal key is present in ~/.ssh, sudo will use it over the yubikey.
      "sshKeys/id_ed25519".path = lib.mkForce "${homeDir}/.ssh/id_manual.key";
      "sshKeys/id_yubi5c".path = "${homeDir}/.ssh/id_yubi5c";
      "sshKeys/id_yubinano".path = "${homeDir}/.ssh/id_yubinano";
    };

    programs.ssh = {
      extraConfig = lib.mkAfter ''
        AddKeysToAgent yes
        Host *
          ForwardAgent yes
          IdentityFile ~/.ssh/id_yubikey
          IdentityFile ~/.ssh/id_manual.key
      '';
    };

    # passwordless sudo
    sops.secrets."u2f_keys".path = "${homeDir}/.config/Yubico/u2f_keys";
  };
}
