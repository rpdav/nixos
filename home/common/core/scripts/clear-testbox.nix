{
  pkgs,
  config,
}:
# Deletes ip and hostname entries for testbox host.
# Prevents ssh warnings after rebuilding with new
# ssh keys
pkgs.writeShellScriptBin "clear-testbox" ''
  sed --in-place --follow-symlinks "/10.10.1.18/d" ${config.programs.ssh.matchBlocks."*".data.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/10.10.1.18/d" /root/.ssh/known_hosts
  sed --in-place --follow-symlinks "/testbox/d" ${config.programs.ssh.matchBlocks."*".data.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/testbox/d" /root/.ssh/known_hosts
''
