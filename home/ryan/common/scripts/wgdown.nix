{ pkgs }:

  pkgs.writeShellScriptBin "wgdown" ''
   sudo systemctl restart wg-quick-$1.service
  ''
