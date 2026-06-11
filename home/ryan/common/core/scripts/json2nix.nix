{pkgs}:
pkgs.writeShellScriptBin "json2nix" ''
  nix eval --impure --expr "builtins.fromJSON (builtins.readFile $1)"
''
