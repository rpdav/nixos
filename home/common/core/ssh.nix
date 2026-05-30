{
  lib,
  config,
  osConfig,
  configLib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  username = config.home.username;
  # Path to public keys stored in config
  pathtokeys = configLib.relativeToRoot "system/common/users/${username}/keys";
  # List of public keys in path
  pubKeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
    # Remove the .pub suffix
    (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  # Create set of keys to be symlinked by home.file
  publicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
    # list of dicts
    (key: {".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub";})
    pubKeys
  );
in {
  # Pull manual key from sops
  # This gets overridden by the yubikey module if it's in use
  sops.secrets = {
    "sshKeys/id_ed25519".path = "${homeDir}/.ssh/id_manual";
  };

  # symlink public keys
  home.file =
    {
    }
    // publicKeyEntries;

  # General ssh config
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; #this will eventually be deprecated and can be removed
    settings."*" = {
      # For impermanent systems, known hosts must be written to persistent volume. if !impermanent, it goes to default location.
      userKnownHostsFile =
        if config.userOpts.impermanent
        then "${osConfig.systemOpts.persistVol}${homeDir}/.ssh/known_hosts"
        else "${homeDir}/.ssh/known_hosts";
      forwardAgent = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      compression = false;
      hashKnownHosts = false;
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
}
