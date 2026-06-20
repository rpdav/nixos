{...}: {
  flake.homeModules.core = {
    config,
    osConfig,
    ...
  }: let
    inherit (config.home) homeDirectory username;
    # Function to symlink user's authorized pub keys from host config into ~/.ssh
    pubKeys = osConfig.users.users.${username}.openssh.authorizedKeys.keyFiles;
    keyToAttribute = path: let
      pathString = toString path;
      filename = baseNameOf pathString;
    in {
      name = filename;
      value = {
        source = path;
        target = ".ssh/${filename}";
      };
    };
    homeFileConfig = builtins.listToAttrs (map keyToAttribute pubKeys);
  in {
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

    # Pull manual key from sops
    # This gets overridden by the yubikey module if it's in use
    sops.secrets = {
      "sshKeys/id_ed25519".path = "${homeDirectory}/.ssh/id_manual";
    };

    # symlink public keys from osConfig
    home.file = homeFileConfig;
  };
}
