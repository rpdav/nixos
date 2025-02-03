{
  lib,
  userOpts,
  systemOpts,
  config,
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
  };
}
