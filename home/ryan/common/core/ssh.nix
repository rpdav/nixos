{
  lib,
  userOpts,
  systemOpts,
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
    userKnownHostsFile = lib.mkIf systemOpts.impermanent "${systemOpts.persistVol}/home/${userOpts.username}/.ssh/known_hosts";
    extraConfig = ''
      Host nas
        HostName 10.10.1.17
       	User ryan
       	Port 22

      Host pi
       	HostName 10.10.1.10
       	User pi
       	Port 22

      Host vps
	Hostname 170.187.148.177
        User ryan

      Host borg
        Hostname 10.10.1.17
	Port 2222
        User borg

      Host testbox
	Hostname 10.10.1.18
	User ryan

      Host testvm
	Hostname 10.10.1.19
	User ryan

      Host gitea.dfrp.xyz
        User git
	Port 2223

      Host github.com
	User git
    '';
  };
}
