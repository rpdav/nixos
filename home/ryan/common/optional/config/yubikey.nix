{
  lib,
  userOpts,
  systemOpts,
  ...
}: {
  # Pull private keys from sops
  sops.secrets = {
    # override default manual key path if yubikey is enabled. If normal key is present in .ssh, sudo will use it over the yubikey.
    "${userOpts.username}/sshKeys/id_manual".path = lib.mkForce "/home/${userOpts.username}/.ssh/id_manual.key";
    "${userOpts.username}/sshKeys/id_yubi5c".path = "/home/${userOpts.username}/.ssh/id_yubi5c";
    "${userOpts.username}/sshKeys/id_yubinano".path = "/home/${userOpts.username}/.ssh/id_yubinano";
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
  services.yubikey-touch-detector.enable = lib.mkIf systemOpts.gui true;

  # passwordless sudo
  sops.secrets."${userOpts.username}/u2f_keys".path = "/home/${userOpts.username}/.config/Yubico/u2f_keys";
}
