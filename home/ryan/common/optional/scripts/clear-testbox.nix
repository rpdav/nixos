{
  pkgs,
  userOpts,
}:
# Deletes ip and hostname entries for testbox host.
# Prevents ssh warnings after rebuilding with new
# ssh keys
pkgs.writeShellScriptBin "clear-testbox" ''
  sed -i "/10.10.1.18/d" /persist/home/${userOpts.username}/.ssh/known_hosts
  sudo sed -i "/10.10.1.18/d" /root/.ssh/known_hosts
  sed -i "/testbox/d" /persist/home/${userOpts.username}/.ssh/known_hosts
  sudo sed -i "/testbox/d" /root/.ssh/known_hosts
''
