{...}: {
  flake.homeModules.core = {
    lib,
    config,
    osConfig,
    configLib,
    ...
  }: let
    inherit (config.home) homeDirectory username;
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
      "sshKeys/id_ed25519".path = "${homeDirectory}/.ssh/id_manual";
    };

    # symlink public keys
    home.file = {} // publicKeyEntries;

    # General ssh config
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; #this will eventually be deprecated and can be removed
      settings."*" = {
        userKnownHostsFile = "${osConfig.systemOpts.persistVol}${homeDirectory}/.ssh/known_hosts";
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
  };
}
