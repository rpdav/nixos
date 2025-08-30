{
  pkgs,
  config,
}:
# Deletes ip and hostname entries for testvm host.
# Prevents ssh warnings after rebuilding with new
# ssh keys
pkgs.writeShellScriptBin "clear-testvm" ''
  sed --in-place --follow-symlinks "/10.10.1.19/d" ${config.programs.ssh.matchBlocks."*".data.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/10.10.1.19/d" /root/.ssh/known_hosts
  sed --in-place --follow-symlinks "/testvm/d" ${config.programs.ssh.matchBlocks."*".data.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/testvm/d" /root/.ssh/known_hosts
''
