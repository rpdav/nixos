{ pkgs }:

  pkgs.writeShellScriptBin "wgup" ''
    sudo ${pkgs.wireguard-tools}/bin/wg-quick up $1
  ''
