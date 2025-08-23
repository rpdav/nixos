{pkgs}:
pkgs.writeShellScriptBin "toml2nix" ''
  nix eval --impure --expr "builtins.fromTOML (builtins.readFile $1)"
''
