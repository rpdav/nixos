{ pkgs }:

  pkgs.writeShellScriptBin "wgdown" ''
    sudo ${pkgs.wireguard-tools}/bin/wg-quick down $1
  ''
