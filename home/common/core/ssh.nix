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
    enableDefaultConfig = false;
    matchBlocks."*" = {
      # For impermanent systems, known hosts must be written to persistent volume. if !impermanent, it goes to default location.
      userKnownHostsFile = lib.mkIf osConfig.systemOpts.impermanent "${osConfig.systemOpts.persistVol}${homeDir}/.ssh/known_hosts";
      # The options below are defaults from programs.ssh.enableDefaultConfig, which is deprecated
      # May want to revisit these someday
      forwardAgent = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      compression = false;
      addKeysToAgent = "no";
      hashKnownHosts = false;
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
}
