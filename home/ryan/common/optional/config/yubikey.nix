{
  lib,
  userSettings,
  ...
}: {
  # Pull private keys from sops
  sops.secrets = {
    # override default manual key path if yubikey is enabled. If normal key is present in .ssh, sudo will use it over the yubikey.
    "${userSettings.username}/sshKeys/id_manual".path = lib.mkForce "/home/${userSettings.username}/.ssh/id_manual.key";
    "${userSettings.username}/sshKeys/id_yubi5c".path = "/home/${userSettings.username}/.ssh/id_yubi5c";
    "${userSettings.username}/sshKeys/id_yubi5pink".path = "/home/${userSettings.username}/.ssh/id_yubi5pink";
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
  services.yubikey-touch-detector.enable = true;

  # passwordless sudo
  sops.secrets."${userSettings.username}/u2f_keys".path = "/home/${userSettings.username}/.config/Yubico/u2f_keys";
}
