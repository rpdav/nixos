{pkgs}:
pkgs.writeShellScriptBin "wgup" ''
  sudo systemctl restart wg-quick-$1.service
''
