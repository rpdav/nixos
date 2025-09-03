{
  lib,
  config,
  osConfig,
  outputs,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  imports = [outputs.homeManagerModules.yubikey-touch-detector];
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

  # visual notification for yubikey touch
  services.yubikey-touch-detector.enable = lib.mkIf osConfig.systemOpts.gui true;

  # passwordless sudo
  sops.secrets."u2f_keys".path = "${homeDir}/.config/Yubico/u2f_keys";
}
