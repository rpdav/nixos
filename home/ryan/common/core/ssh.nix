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
  pathtokeys = configLib.relativeToRoot "hosts/common/users/${username}/keys";
  # List of public keys in path
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
    # Remove the .pub suffix
    (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  # Create set of keys to be symlinked by home.file
  publicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
    # list of dicts
    (key: {".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub";})
    yubikeys
  );
in {
  # Pull manual key from sops
  # This gets overridden by the yubikey module if it's in use
  sops.secrets = {
    "${username}/sshKeys/id_manual".path = "${homeDir}/.ssh/id_manual";
  };

  # symlink public keys
  home.file =
    {
    }
    // publicKeyEntries;

  # General ssh config
  programs.ssh = {
    enable = true;

    # For impermanent systems, nown hosts must be written to persistent volume. if !impermanent, it goes to default location.
    userKnownHostsFile = lib.mkIf osConfig.systemOpts.impermanent "${osConfig.systemOpts.persistVol}${homeDir}/.ssh/known_hosts";
  };
}
