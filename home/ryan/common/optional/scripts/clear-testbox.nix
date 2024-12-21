{pkgs}:

# Deletes ip and hostname entries for testbox host.
# Prevents ssh warnings after rebuilding with new
# ssh keys

pkgs.writeShellScriptBin "clear-testbox" ''
  sed -i "/10.10.1.18/d" ~/.ssh/known_hosts
  sudo sed -i "/10.10.1.18/d" /root/.ssh/known_hosts
  sed -i "/testbox/d" ~/.ssh/known_hosts
  sudo sed -i "/testbox/d" /root/.ssh/known_hosts
''
