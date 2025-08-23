{pkgs}:
pkgs.writeShellScriptBin "yaml2nix" ''
  cat $1 | ${pkgs.yj}/bin/yj -i > ./temp.json
  json2nix ./temp.json
  rm temp.json
''
