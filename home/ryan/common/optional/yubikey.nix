{
  lib,
  osConfig,
  ...
}: {
  # Pull private keys from sops
  sops.secrets = {
    # override default manual key path if yubikey is enabled. If normal key is present in .ssh, sudo will use it over the yubikey.
    "ryan/sshKeys/id_ed25519".path = lib.mkForce "/home/ryan/.ssh/id_manual.key";
    "ryan/sshKeys/id_yubi5c".path = "/home/ryan/.ssh/id_yubi5c";
    "ryan/sshKeys/id_yubinano".path = "/home/ryan/.ssh/id_yubinano";
  };

  # modify ssh config for yubikeys
  programs.ssh = {
    extraConfig = ''
      # req'd for enabling yubikey-agent
      AddKeysToAgent yes

      Host *
        # symlink to current yubikey
        IdentityFile ~/.ssh/id_yubikey
        # fallback to manual key
        IdentityFile ~/.ssh/id_manual.key
    '';
  };

  # visual notification for yubikey touch
  services.yubikey-touch-detector.enable = lib.mkIf osConfig.systemOpts.gui true;

  # passwordless sudo
  sops.secrets."ryan/u2f_keys".path = "/home/ryan/.config/Yubico/u2f_keys";
}
