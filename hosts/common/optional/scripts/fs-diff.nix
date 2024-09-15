{ pkgs }:

  pkgs.writeShellScriptBin "fs-diff" ''
    sudo ${pkgs.findutils}/bin/find $1 -mount ! -type l,d
  ''
