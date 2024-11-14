{ pkgs }:

  pkgs.writeShellScriptBin "wgdown" ''
   sudo systemctl stop wg-quick-$1.service
  ''
