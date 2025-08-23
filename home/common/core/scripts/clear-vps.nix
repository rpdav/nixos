{
  pkgs,
  config,
}:
# Deletes ip and hostname entries for vps host.
# Prevents ssh warnings after rebuilding with new
# ssh keys
pkgs.writeShellScriptBin "clear-vps" ''
  sed --in-place --follow-symlinks "/170.187.148.177/d" /persist/home/${config.programs.ssh.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/170.187.148.177/d" /root/.ssh/known_hosts
  sed --in-place --follow-symlinks "/vps/d" /persist/home/${config.programs.ssh.userKnownHostsFile};
  sudo sed --in-place --follow-symlinks "/vps/d" /root/.ssh/known_hosts
''
