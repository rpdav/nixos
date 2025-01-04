{
  config,
  pkgs,
  lib,
  userOpts,
  configLib,
  ...
}: let
  # Path to public keys stored in config
  pathtokeys = configLib.relativeToRoot "hosts/common/users/${userOpts.username}/keys";
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
    "${userOpts.username}/sshKeys/id_manual".path = "/home/${userOpts.username}/.ssh/id_manual";
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
	Hostname 100.108.25.120 #tailscale IP
      	User root
      	Port 44422

      Host borg
        Hostname 10.10.1.16
        User borg

      Host testbox
	Hostname 10.10.1.18
	User ryan

      Host testvm
	Hostname 10.10.1.19
	User ryan

      Host gitea.dfrp.xyz github.com
        User git

      Host vps
	User root
    '';
  };
}
