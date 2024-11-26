{
  config,
  pkgs,
  lib,
  userSettings,
  configLib,
  ...
}: let
  # Path to public keys stored in config
  pathtokeys = configLib.relativeToRoot "hosts/common/users/${userSettings.username}/keys";
  # List of public keys in path
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
    # Remove the .pub suffix
    (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  # Create set of keys to be symlinked by home.file
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
    # list of dicts
    (key: {".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub";})
    yubikeys
  );
in {
  # Pull private key from sops
  sops.secrets = {
    "${userSettings.username}/sshKeys/id_manual".path = "/home/${userSettings.username}/.ssh/id_manual";
  };

  # symlink public keys
  home.file =
    {
    }
    // yubikeyPublicKeyEntries;

  # General ssh config
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host nas
      	HostName 10.10.1.17
      	User root
      	Port 22

      Host pi
      	HostName 10.10.1.10
      	User pi
      	Port 22

      Host vps
      	HostName 10.100.94.1 #wireguard IP
      	User root
      	Port 44422

      Host pve
      	Hostname 10.10.1.18
      	User root
      	Port 22

      Host borg
        Hostname 10.10.1.16
        User borg

      Host gitea.dfrp.xyz github.com
        User git
    '';
  };
}
