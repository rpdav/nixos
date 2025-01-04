{pkgs}:

# Deletes ip and hostname entries for testvm host.
# Prevents ssh warnings after rebuilding with new
# ssh keys

pkgs.writeShellScriptBin "clear-testvm" ''
  sed -i "/10.10.1.19/d" ~/.ssh/known_hosts
  sudo sed -i "/10.10.1.19/d" /root/.ssh/known_hosts
  sed -i "/testvm/d" ~/.ssh/known_hosts
  sudo sed -i "/testvm/d" /root/.ssh/known_hosts
''
