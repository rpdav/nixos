{self, ...}: {
  flake.nixosModules.yubikey = {lib, ...}: {
    imports = [self.modules.nixos.yubikey];
    # enable keys and set identifiers
    yubikey = {
      enable = true;
      identifiers = {
        yubi5c = 23559438;
        yubinano = 31767330;
      };
    };

    programs.yubikey-touch-detector.enable = true;

    security.pam.services.login.u2fAuth = lib.mkForce false; # Enabled in yubikey module by default; I prefer password login since I leave my key in at all times
  };
  flake.homeModules.yubikey = {
    lib,
    config,
    ...
  }: let
    homeDir = config.home.homeDirectory;
  in {
    # Pull private keys from sops
    sops.secrets = {
      # override default manual key path if yubikey is enabled. If normal key is present in .ssh, sudo will use it over the yubikey.
      "sshKeys/id_ed25519".path = lib.mkForce "${homeDir}/.ssh/id_manual.key";
      "sshKeys/id_yubi5c".path = "${homeDir}/.ssh/id_yubi5c";
      "sshKeys/id_yubinano".path = "${homeDir}/.ssh/id_yubinano";
    };

    # modify ssh config for yubikeys
    programs.ssh = {
      extraConfig = lib.mkAfter ''
        # req'd for enabling yubikey-agent
        AddKeysToAgent yes
        Host *
          # symlink to current yubikey
          IdentityFile ~/.ssh/id_yubikey
          # fallback to manual key
          IdentityFile ~/.ssh/id_manual.key
      '';
    };

    # passwordless sudo
    sops.secrets."u2f_keys".path = "${homeDir}/.config/Yubico/u2f_keys";
  };
}
