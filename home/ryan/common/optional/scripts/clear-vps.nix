{
  pkgs,
  userOpts,
}:
# Deletes ip and hostname entries for vps host.
# Prevents ssh warnings after rebuilding with new
# ssh keys
pkgs.writeShellScriptBin "clear-vps" ''
  sed -i "/170.187.148.177/d" /persist/home/${userOpts.username}/.ssh/known_hosts
  sudo sed -i "/170.187.148.177/d" /root/.ssh/known_hosts
  sed -i "/vps/d" /persist/home/${userOpts.username}/.ssh/known_hosts
  sudo sed -i "/vps/d" /root/.ssh/known_hosts
''
